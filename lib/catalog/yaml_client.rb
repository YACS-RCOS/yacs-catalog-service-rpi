require 'YAML'

module Catalog
  class YamlClient
    def initialize filename='config/schools.yml'
      @filename = filename
    end

    def departments
      schools.map {|s| s[:departments]}.flatten
    end

    def schools
      YAML.load(File.open(@filename))[:schools]
    end
  end
end