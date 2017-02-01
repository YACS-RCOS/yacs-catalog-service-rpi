require 'nokogiri'
require 'open-uri'

module Catalog
  def current_catalog

  end

  def sections
    uri = "https://sis.rpi.edu/reg/rocs/YACS_#{SEMESTER}.xml"
    sections = Nokogiri::XML(open(uri)).xpath("//CourseDB/SECTION")
    sections.map do |xml|
      section = xml.to_h.select!{|s| %w(crn num students seats).include?(s)}
      section.map{|k, v| [k == 'students' ? 'seats_taken' : k, v]}.to_h
    end
  end

  def courses
    uri = "https://sis.rpi.edu/reg/rocs/#{sem_string}.xml"
    courses = Nokogiri::XML(open(uri)).xpath('//COURSE')
    courses.map do |xml|
      course = xml.to_h.map do |k, v|
        case k
        when :credmin then [:min_credits, v]
        when :credmax then [:max_credits, v]
        when :num     then [:number, v]
        when :name    then [:name, v.titleize]
        when :dept    then [:department, { code: v }]
        else nil
        end
      end.to_h.compact!
      course[:sections] = extract_sections xml
      course
    end
  end

  def departments
    schools.map {|s| s[:departments]}.flatten
  end

  def schools
    YAML.load(File.open('config/schools.yml'))[:schools]
  end

  private

  def extract_sections course
    course.xpath('SECTION').map do |xml|
      section = xml.to_h.map do |k, v|
        case k
        when :num       then [:name, v]
        when :crn       then [:crn, v]
        when :seats     then [:seats, v]
        when :students  then [:seats_taken, v]
        else nil
        end
      end.to_h.compact!
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
      section[:instructors].uniq!.delete 'Staff'
      section
    end
  end
end
