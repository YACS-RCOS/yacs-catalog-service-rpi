require 'yaml'

module Catalog
  class YamlClient
    def initialize filename='config/schools.yml'
      @filename = filename
      @schools
    end

    def departments
      schools.map {|s| s[:departments]}.flatten
    end

    def schools
      @schools = YAML.load_file(@filename)
      puts @schools.inspect
      YAML.dump(@filename)
    end
  end
end