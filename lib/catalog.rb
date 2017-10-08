require './lib/catalog/acalog_client'
require './lib/catalog/banner_client'
require './lib/catalog/yaml_client'

module Catalog
  BANNER_SECTIONS_URI = ENV['BANNER_SECTIONS_URI'] # "https://sis.rpi.edu/reg/rocs/YACS_201709.xml"
  BANNER_COURSES_URI = ENV['BANNER_COURSES_URI'] # "https://sis.rpi.edu/reg/rocs/201709.xml"
  ACALOG_API_URI = ENV['ACALOG_API_URI'] # "http://rpi.apis.acalog.com"
  ACALOG_API_KEY = ENV['ACALOG_API_KEY'] # "3eef8a28f26fb2bcc514e6f1938929a1f9317628"

  class Aggregator
    def initialize
      @yaml_client = YamlClient.new
      @banner_client = BannerClient.new BANNER_COURSES_URI, BANNER_SECTIONS_URI
      @acalog_client = AcalogClient.new ACALOG_API_URI, ACALOG_API_KEY
      @acalog_client.load_current_catalog
    end

    def sections 
      @banner_client.sections
    end
    
    def section_seats
      @banner_client.section_seats
    end

    def courses
      @banner_client.courses.map do |course|
        acalog_course = @acalog_client.find(course[:department][:code], course[:number])
        merged_course = course
        merged_course.merge(acalog_course.slice(:name, :description)) if acalog_course
        merged_course
      end
    end

    def departments
      @yaml_client.departments
    end

    def schools
      @yaml_client.schools
    end
  end
end
