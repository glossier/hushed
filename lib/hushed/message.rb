module Hushed
  class Message
    NAMESPACE = 'http://schemas.quietlogistics.com/V2/EventMessage.xsd'.freeze

    class MissingDocumentError < StandardError; end
    class MissingClientError < StandardError; end

    attr_reader :client, :document, :xml

    def initialize(options = {})
      @xml = Nokogiri::XML::Document.parse(options[:xml]) if options[:xml]
      @client = options[:client]
      @document = options[:document]
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.EventMessage(attributes)
      end
      builder.to_xml
    end

    def document_type
      @document ? @document.type : @xml.css('EventMessage').first['DocumentType']
    end

    def document_name
      @document ? @document.filename : @xml.css('EventMessage').first['DocumentName']
    end

    def attributes
      raise MissingClientError, 'client cannot be missing' unless @client
      raise MissingDocumentError, 'document cannot be missing' unless @document
      {
        ClientId: @client.client_id, BusinessUnit: @client.business_unit,
        DocumentName: @document.filename, DocumentType: @document.type,
        Warehouse: @document.warehouse, MessageDate: @document.date.utc.iso8601,
        MessageId: @document.message_id, xmlns: NAMESPACE
      }
    end
  end
end
