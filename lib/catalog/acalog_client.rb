require 'active_support/core_ext'

module Catalog
  class AcalogClient
    ACALOG_FIELD_TYPES = {
      description: 343,
      department_code: 358,
      number: 360,
      name: 362
    }.with_indifferent_access.freeze!

    def initialize api_url, api_key
      @api_url = api_url
      @api_key = api_key
      @catalog_id = current_catalog_id
    end

    def courses
      mapped_courses = {}
      response = request(methods: :getCourses, 'ids[]': course_ids))
      response.xpath('//course/content').each do |course_xml|
        course = ACALOG_FIELD_TYPES.map do |k, v|
          [k, course_xml.xpath("/field[type = 'acalog-field-#{v}']")]
        end.to_h
        mapped_courses[course[:department_code]] ||= {}
        mapped_courses[course[:department_code]][course[:number]] = course
      end
    end

    def course_ids
      params = { method: listing, catalog_id: current_catalog_id, 'options[limit]': 0 }
      request(params).xpath('//result//id/text()').map(&:text)
    end

    private

    def current_catalog_id
      node = request(method: :getCatalog).
        xpath('//catalog[state/published = "Yes" and state/archived = "No"]/@id')
      @catalog_id = /acalog-catalog-(?<id>\d+)/.match(node.text)[:id].to_i
    end

    def request params
      uri = "http://#{@url}/v1/content?key=#{api_key}&format=xml&#{params.to_query}"
      Nokogiri::HTML(open(uri))
    end
  end
end