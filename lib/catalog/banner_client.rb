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
        section[:instructors]   = []
        section[:periods_day]   = []
        section[:periods_start] = []
        section[:periods_end]   = []
        section[:periods_type]  = []
        xml.xpath('PERIOD').each do |pxml|
          section[:instructors].concat(pxml[:instructor].strip.split(/\//))
          pxml.xpath('DAY').each do |dxml|
            dxml.each do |day|
              section[:periods_day]   << day_xml.text.to_i + 1
              section[:periods_start] << pxml[:start]
              section[:periods_end]   << pxml[:end]
              section[:periods_type]  << pxml[:type]
            end
          end
        end
        section[:num_periods] = section[:periods_day].count
        section[:instructors].uniq!
        section[:instructors].delete 'Staff'
        section
      end
    end
  end
end
