require 'nokogiri'
require 'open-uri'

module Catalog
  def sections
    uri = "https://sis.rpi.edu/reg/rocs/YACS_#{SEMESTER}.xml"
    sections = Nokogiri::XML(open(uri)).xpath("//CourseDB/SECTION")
    sections.map do |xml|
      section = xml.to_h.select!{|s| %w(crn num students seats).include?(s)}
      section.map{|k, v| [k == 'students' ? 'seats_taken' : k, v]}.to_h
    end
  end

  def courses

  end

  def departments
    get_schools[:schools].map {|s| s[:departments]}.flatten
  end

  def schools
    YAML.load(File.open('config/schools.yml'))
  end
end
