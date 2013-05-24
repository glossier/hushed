require 'nokogiri'

module Hushed
  class Message

    NAMESPACE = "http://schemas.quietlogistics.com/V2/EventMessage.xsd"

    class MissingDocumentError < StandardError; end
    class MissingClientError < StandardError; end

    attr_reader :client, :document

    def initialize(options = {})
      @client = options[:client] || raise(MissingClientError.new("client cannot be missing"))
      @document = options[:document] || raise(MissingDocumentError.new("document cannot be missing"))
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.EventMessage(attributes)
      end
      builder.to_xml
    end

    def attributes
      {
        ClientId: @client.client_id, BusinessUnit: @client.business_unit,
        DocumentName: @document.name, DocumentType: @document.type,
        Warehouse: @document.warehouse, MessageDate: @document.date.utc,
        MessageId: @document.message_id, xmlns: NAMESPACE
      }
    end
  end
end