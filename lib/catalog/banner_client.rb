require 'nokogiri'
require 'httpclient'
require 'pry'

module Catalog
  class BannerClient

    def initialize courses_uri, sections_uri
      @courses_uri = courses_uri
      @sections_uri = sections_uri
      @http_client = HTTPClient.new
    end

    def sections
      sections = get_xml(@sections_uri).xpath('//CourseDB/SECTION')
      sections.map do |xml|
        section = xml.to_h.select!{|s| %w(crn num students seats).include?(s)}
        section.map{|k, v| [k == 'students' ? 'seats_taken' : k, v]}.to_h
      end
    end

    def courses
      courses = get_xml(@courses_uri).xpath('//COURSE')
      courses.map do |xml|
        course = xml.to_h.symbolize_keys.map do |k, v|
          case k
          when :credmin then [:min_credits, v]
          when :credmax then [:max_credits, v]
          when :num     then [:number, v]
          when :name    then [:name, v.titleize]
          when :dept    then [:department, { code: v }]
          else [nil, nil]
          end
        end.to_h.compact
        course[:sections] = extract_sections xml
        course
      end
    end

    private

    def get_xml uri
      Nokogiri::XML(@http_client.get(uri).body)
    end

    def extract_sections course
      course.xpath('SECTION').map do |xml|
        section = xml.to_h.symbolize_keys.map do |k, v|
          case k
          when :num       then [:name, v]
          when :crn       then [:crn, v]
          when :seats     then [:seats, v]
          when :students  then [:seats_taken, v]
          else [nil, nil]
          end
        end.to_h.compact
        section[:periods] = extract_periods xml
        section[:instructors]   = []
        xml.xpath('PERIOD').each do |pxml|
          section[:instructors].concat(pxml[:instructor].strip.split(/\//))
        end
        section[:instructors].uniq!
        section[:instructors].delete 'Staff'
        section
      end
    end

    def extract_periods section
      section.xpath('PERIOD').map do |pxml|
        period = pxml.to_h.symbolize_keys.map do |k,v|
          case k
          when :instructor 
            v.strip.split(/\//)
            [:instructor, v.strip.split(/\//)]
          when :type        then [:type, v]
          when :start       then [:start, v]
          when :end         then [:end, v]
          when :location    then [:location, v]
          else [nil, nil]
          end
        end.to_h.compact
        period[:days] = []
        pxml.element_children.each do |day|
          period[:days] << day.text.to_i+1
        end
        period
      end
    end
  end
end
