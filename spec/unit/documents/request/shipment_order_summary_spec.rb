require 'spec_helper'
require 'hushed/documents/request/shipment_order_summary'

module Hushed
  module Documents
    module Request
      describe "ShipmentOrderSummary" do
        before do
          @client = ClientDouble.new(:client_id => 'CLIENT', :business_unit => 'BUSINESS', :warehouse => 'WAREHOUSE')
        end

        it "should be able to generate an shipment order summary request xml document" do
          message = ShipmentOrderSummary.new(client: @client)
          document = Nokogiri::XML(message.to_xml)

          expected_namespaces = {'xmlns' => 'http://schemas.quietlogistics.com/V2/ShipmentOrderSummaryRequest.xsd'}
          assert_equal expected_namespaces, document.collect_namespaces()

          document.remove_namespaces!
          assert_equal "CLIENT", document.xpath("/ShipmentOrderSummaryRequest/@ClientId").first.value
          assert_equal "BUSINESS", document.xpath("/ShipmentOrderSummaryRequest/@BusinessUnit").first.value
          assert_equal "WAREHOUSE", document.xpath("/ShipmentOrderSummaryRequest/@Warehouse").first.value
        end
      end
    end
  end
end
