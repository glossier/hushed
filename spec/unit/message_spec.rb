require 'spec_helper'
require 'hushed/message'

module Hushed
  describe "Message" do
    include Fixtures
    before do
      prepare_models
    end

    it "should be possible to initialize a Message" do
      message = Message.new(:document => @document, :client => @client)
      assert_equal @document, message.document
      assert_equal @client, message.client
    end

    it "should raise an error if the document is missing when trying to generate XML" do
      message = Message.new(:client => @client)
      assert_raises Message::MissingDocumentError do
        message.to_xml
      end
    end

    it "should raise an error if the client is missing when trying to generate XML" do
      message = Message.new(:document => @document)
      assert_raises Message::MissingClientError do
        message.to_xml
      end
    end

    it "should be possible to create a Message with XML and query it for information" do
      message = Message.new(:xml => load_message('purchase_order_message'))

      assert_equal 'PurchaseOrder', message.document_type
      assert_equal 'HUSHED_PurchaseOrder_1234_20100927_132505124.xml', message.document_name
    end

    it "should be able to generate an XML document" do
      message = Message.new(:document => @document, :client => @client)
      document = Nokogiri::XML::Document.parse(message.to_xml)

      expected_namespaces = {'xmlns' => Message::NAMESPACE}
      assert_equal expected_namespaces, document.collect_namespaces()

      assert node = document.css('EventMessage').first
      assert_equal @document.type, node['DocumentType']
      assert_equal @document.filename, node['DocumentName']
      assert_equal @document.warehouse, node['Warehouse']
      assert_equal @document.date.utc.to_s, node['MessageDate']
      assert_equal @document.message_id, node['MessageId']

      assert_equal @client.client_id, node['ClientId']
      assert_equal @client.business_unit, node['BusinessUnit']
    end

    def prepare_models
      @document = DocumentDouble.new(
        type: "PurchaseOrder",
        filename: "abracadabra.xml",
        message_id: "alakazam",
        warehouse: "Onett1",
        date: Time.new(2013, 4, 1, 12, 30, 0)
      )

      @client = ClientDouble.new(
        client_id: 'HUSHED',
        business_unit: 'HUSHED'
      )
    end
  end
end