require 'yaml'

module Catalog
  class YamlClient
    def initialize filename='config/schools.yml'
      @filename = filename
    end

    def departments
      schools.map {|s| s['departments']}.flatten
    end

    def schools
      YAML.load_file(@filename)['schools']
    end
  end
end