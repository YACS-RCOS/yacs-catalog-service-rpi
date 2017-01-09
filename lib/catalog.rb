module Catalog
  def get_sections
    uri = "https://sis.rpi.edu/reg/rocs/YACS_#{SEMESTER}.xml"
    sections = Nokogiri::XML(open(uri)).xpath("//CourseDB/SECTION")
    sections.map do |xml|
      section = xml.to_h.select!{|s| %w(crn num students seats).include?(s)}
      section.map{|k, v| [k == 'students' ? 'seats_taken' : k, v]}.to_h
    end
  end

  def get_courses

  end

  def get_departments

  end

  def get_schools

  end
end
