module Hushed
  class ErrorMessage
    attr_reader :xml

    def initialize(options = {})
      @xml = Nokogiri::XML::Document.parse(options[:xml]) if options[:xml]
    end

    def to_xml
      @xml.serialize(encoding: "UTF-8")
    end

    def shipment_number
      result_description = @xml.css("ErrorMessage").first["ResultDescription"]
      match_data = result_description.match(/(.+)_(.+)_(.+)_.*.xml/) unless result_description.nil?
      match_data[2] unless match_data.nil?
    end
  end
end
