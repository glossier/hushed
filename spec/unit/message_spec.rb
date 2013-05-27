require 'spec_helper'
require 'hushed/message'

module Hushed
  describe "Message" do
    before do
      prepare_models
    end

    it "should be possible to initialize a Message" do
      message = Message.new(:document => @document, :client => @client)
      assert_equal @document, message.document
      assert_equal @client, message.client
    end

    it "should raise an error if the document is missing" do
      assert_raises Message::MissingDocumentError do
        Message.new(:client => @client)
      end
    end

    it "should raise an error if the client is missing" do
      assert_raises Message::MissingClientError do
        Message.new(:document => @document)
      end
    end

    it "should be able to generate an XML document" do
      message = Message.new(:document => @document, :client => @client)
      document = Nokogiri::XML::Document.parse(message.to_xml)

      expected_namespaces = {'xmlns' => Message::NAMESPACE}
      assert_equal expected_namespaces, document.collect_namespaces()

      assert node = document.css('EventMessage').first
      assert_equal @document.type, node['DocumentType']
      assert_equal @document.name, node['DocumentName']
      assert_equal @document.warehouse, node['Warehouse']
      assert_equal @document.date.utc.to_s, node['MessageDate']
      assert_equal @document.message_id, node['MessageId']

      assert_equal @client.client_id, node['ClientId']
      assert_equal @client.business_unit, node['BusinessUnit']
    end

    def prepare_models
      @document = DocumentDouble.new
      @document.type = "PurchaseOrder"
      @document.name = "abracadabra.xml"
      @document.message_id = "alakazam"
      @document.warehouse = "Onett1"
      @document.date = Time.new(2013, 4, 1, 12, 30, 0)

      @client = ClientDouble.new
      @client.client_id = 'HUSHED'
      @client.business_unit = 'HUSHED'
    end
  end
end