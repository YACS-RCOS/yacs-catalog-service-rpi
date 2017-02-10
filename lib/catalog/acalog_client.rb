require 'active_support/core_ext'

module Catalog
  class AcalogClient
    ACALOG_FIELD_TYPES = {
      description: 343,
      department_code: 358,
      number: 360,
      name: 362
    }.freeze

    def initialize api_url, api_key
      @api_url = api_url
      @api_key = api_key
    end

    def load_current_catalog
      @courses = courses(current_catalog_id).freeze
    end

    def find department_code, number
      @courses[department_code.to_s][number.to_s]
    end

    private

    def course_ids catalog_id
      params = {
        method: listing,
        catalog_id: catalog_id,
        'options[limit]': 0
      }
      request(params).xpath('//result//id/text()').map(&:text)
    end

    def courses catalog_id
      mapped_courses = {}
      ids = course_ids catalog_id
      response = request(methods: :getCourses, 'ids[]': ids))
      response.xpath('//course/content').each do |course_xml|
        course = ACALOG_FIELD_TYPES.map do |k, v|
          [k, course_xml.xpath("/field[type = 'acalog-field-#{v}']")]
        end.to_h
        mapped_courses[course[:department_code]] ||= {}
        mapped_courses[course[:department_code]][course[:number]] = course
      end
      mapped_courses
    end

    def current_catalog_id
      node = request(method: :getCatalog).
        xpath('//catalog[state/published = "Yes" and state/archived = "No"]/@id')
      @catalog_id = /acalog-catalog-(?<id>\d+)/.match(node.text)[:id].to_i
    end

    def request params
      params = params.merge({ key: @api_key, format: :xml })
      uri = "http://#{@api_url}/v1/content?#{params.to_query}"
      Nokogiri::HTML(open(uri))
    end
  end
end
