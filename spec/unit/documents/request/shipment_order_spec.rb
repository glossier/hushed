require 'spec_helper'
require 'hushed/documents/request/shipment_order'

module Hushed
  module Documents
    module Request
      describe "ShipmentOrder" do

        before do
          @shipment = ShipmentDouble.example
          @order = @shipment.order
          @client = ClientDouble.new(:client_id => 'HUSHED', :business_unit => 'HUSHED', :warehouse => 'SPACE')
          @object = @shipment_oddrder = ShipmentOrder.new(shipment: @shipment, client: @client)
        end

        it "should raise an error if an shipment wasn't passed in" do
          assert_raises KeyError do
            ShipmentOrder.new(client: @client)
          end
        end

        it "should be able to generate an XML document" do
          message = ShipmentOrder.new(:shipment => @shipment, :client => @client)
          document = Nokogiri::XML::Document.parse(message.to_xml)

          expected_namespaces = {'xmlns' => ShipmentOrder::NAMESPACE}
          assert_equal expected_namespaces, document.collect_namespaces()

          assert_equal 1, document.css('ShipOrderDocument').length

          assert_equal @client.client_id, document.css('ClientID').first.text
          assert_equal @client.business_unit, document.css('BusinessUnit').first.text

          assert_header(document.css('OrderHeader').first)

          assert_shipping(document.css('ShipMode').first)

          assert_address(@order.email, @order.shipping_address, document.css('ShipTo').first)
          assert_address(@order.email, @order.billing_address, document.css('BillTo').first)

          order_details = document.css('OrderDetails')
          assert_equal 1, order_details.length
          assert_order_details(@shipment.inventory_units_to_fulfill.first, order_details.first)
        end

        it "the XML document should have the associated gift attributes set if the order's gift exists" do
          message = ShipmentOrder.new(:shipment => @shipment, :client => @client)
          document = Nokogiri::XML::Document.parse(message.to_xml)

          assert_equal 'true', document.css('OrderHeader')[0]['Gift']
          assert_equal "GIFTFROM", document.css('Notes')[0]['NodeType']
          assert_equal "from", document.css('Notes')[0]['NodeValue']
          assert_equal "GIFTTO", document.css('Notes')[1]['NodeType']
          assert_equal "to", document.css('Notes')[1]['NodeValue']
          assert_equal "HBD", document.css('Comments')[0].text
        end

        it "the XML document should not have the associated gift attributes set if the order's gift exists" do
          message = ShipmentOrder.new(:shipment => ShipmentDouble.example(order: OrderDouble.example(gift: nil)), :client => @client)
          document = Nokogiri::XML::Document.parse(message.to_xml)

          assert_equal 'false', document.css('OrderHeader')[0]['Gift']
          assert_empty document.css('SONoteType')
          assert_empty document.css('Comments')
        end

        it "uses a sequence as the Line attribute of the OrderDetails" do
          shipment = ShipmentDouble.example(inventory_units_to_fulfill: [
            InventoryUnitDouble.example(variant: VariantDouble.example(sku: "SKU-1")),
            InventoryUnitDouble.example(variant: VariantDouble.example(sku: "SKU-2")),
            InventoryUnitDouble.example(variant: VariantDouble.example(sku: "SKU-3"))
          ])

          message = ShipmentOrder.new(shipment: shipment, client: @client)

          order_details = order_details_from(message)
          assert_equal "1", order_details[0]['Line']
          assert_equal "2", order_details[1]['Line']
          assert_equal "3", order_details[2]['Line']
        end

        it "explodes the line items into parts when applicable" do
          shipment = ShipmentDouble.example(inventory_units_to_fulfill: [
            InventoryUnitDouble.example(variant: VariantDouble.example(sku: "GBB200")),
            InventoryUnitDouble.example(variant: VariantDouble.example(sku: "GSC300")),
            InventoryUnitDouble.example(variant: VariantDouble.example(sku: "GML100")),
            InventoryUnitDouble.example
          ])

          message = ShipmentOrder.new(shipment: shipment, client: @client)

          order_details = order_details_from(message)
          assert_equal 4, order_details.count
          order_details.each { |details| assert_equal "1", details['QuantityOrdered']}
          assert_equal "GBB200", order_details[0]['ItemNumber']
          assert_equal "GSC300", order_details[1]['ItemNumber']
          assert_equal "GML100", order_details[2]['ItemNumber']
        end

        it "groups duplicate line items together" do
          shipment = ShipmentDouble.example(inventory_units_to_fulfill: [
            InventoryUnitDouble.example(variant: VariantDouble.example(sku: "GBB200")),
            InventoryUnitDouble.example(variant: VariantDouble.example(sku: "GBB200")),
            InventoryUnitDouble.example(variant: VariantDouble.example(sku: "GSC300")),
            InventoryUnitDouble.example(variant: VariantDouble.example(sku: "GSC300")),
            InventoryUnitDouble.example(variant: VariantDouble.example(sku: "GML100")),
            InventoryUnitDouble.example(variant: VariantDouble.example(sku: "GBB200"))
          ])

          message = ShipmentOrder.new(shipment: shipment, client: @client)

          order_details = order_details_from(message)
          assert_equal 3, order_details.count
          assert_equal "GBB200", order_details[0]['ItemNumber']
          assert_equal "3", order_details[0]['QuantityOrdered']
          assert_equal "3", order_details[0]['QuantityToShip']
        end

      it 'strips the -set postfix from the SKUS' do
        shipment = ShipmentDouble.example(inventory_units_to_fulfill: [
          InventoryUnitDouble.example(variant: VariantDouble.example(sku: "ABC-SET")),
          InventoryUnitDouble.example(variant: VariantDouble.example(sku: "DEF"))
        ])

        message = ShipmentOrder.new(shipment: shipment, client: @client)

        order_details = order_details_from(message)
        assert_equal "ABC", order_details[0]['ItemNumber']
        assert_equal "DEF", order_details[1]['ItemNumber']
      end

      it 'merges the black tie parts into one bundle' do
        bundle = LineItemDouble.example(sku: "GHOL-16-1001")
        shipment = ShipmentDouble.example(inventory_units_to_fulfill: [
          InventoryUnitDouble.example(variant: VariantDouble.example(sku: "GEYE-01-WIP1-SET"), line_item: bundle),
          InventoryUnitDouble.example(variant: VariantDouble.example(sku: "GNP0-01-WIP1-SET"), line_item: bundle),
          InventoryUnitDouble.example(variant: VariantDouble.example(sku: "GLIP-01-WIP1-SET"), line_item: bundle),
          InventoryUnitDouble.example(variant: VariantDouble.example(sku: "GHS0-03-WIP1-SET"), line_item: bundle),
          InventoryUnitDouble.example
        ])

        message = ShipmentOrder.new(shipment: shipment, client: @client)

        order_details = order_details_from(message)
        assert_equal 2, order_details.count
        assert_includes order_details.map { |detail| detail[:ItemNumber] }, "GHOL-16-1001"
      end

      private

        def assert_header(header)
          assert_equal "#{@shipment.number}", header['OrderNumber']
          assert_equal @shipment.created_at.utc.iso8601.to_s, header['OrderDate']
          assert_equal @order.type, header['OrderType']
        end

        def assert_shipping(shipping)
          assert_equal 'FEDEX', shipping['Carrier']
          assert_equal 'GROUND', shipping['ServiceLevel']
        end

        def assert_order_details(expected, actual)
          assert_equal expected.variant.sku.to_s, actual['ItemNumber']
          assert_equal "1", actual['Line']
          assert_equal "1", actual['QuantityOrdered']
          assert_equal "1", actual['QuantityToShip']
          assert_equal "EA", actual['UOM']
          assert_equal expected.variant.price, actual['Price']
        end

        def assert_address(email, address, node)
          assert_equal address.company, node['Company']
          assert_equal address.name, node['Contact']
          assert_equal address.address1, node['Address1']
          assert_equal address.address2, node['Address2']
          assert_equal address.city, node['City']
          assert_equal address.state.name, node['State']
          assert_equal address.zipcode, node['PostalCode']
          assert_equal address.country.name, node['Country']
        end

        def order_details_from(message)
          document = Nokogiri::XML::Document.parse(message.to_xml)
          document.css('OrderDetails')
        end

      end
    end
  end
end
