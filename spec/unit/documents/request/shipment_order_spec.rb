require 'spec_helper'
require 'hushed/documents/request/shipment_order'

module Hushed
  module Documents
    module Request
      describe "ShipmentOrder" do
        include Hushed::Documents::DocumentInterfaceTestcases

        before do
          @shipment = ShipmentDouble.example
          @order = @shipment.order
          @client = ClientDouble.new(:client_id => 'HUSHED', :business_unit => 'HUSHED', :warehouse => 'SPACE')
          @object = @shipment_order = ShipmentOrder.new(shipment: @shipment, client: @client)
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
          assert_equal @order.note, document.css('Comments').first.text

          assert_shipping(document.css('ShipMode').first)

          assert_address(@order.email, @order.shipping_address, document.css('ShipTo').first)
          assert_address(@order.email, @order.billing_address, document.css('BillTo').first)

          order_details = document.css('OrderDetails')
          assert_equal 1, order_details.length
          assert_line_item(@order.line_items.first, order_details.first)
        end

        it "explodes phase 1 items into individual skus" do
          phase_1_set = LineItemDouble.example(sku: "GPS1-5")
          order = OrderDouble.example(line_items: [
                    phase_1_set,
                    LineItemDouble.example
                  ])
          shipment = ShipmentDouble.example(order: order)

          message = ShipmentOrder.new(:shipment => shipment, :client => @client)

          document = Nokogiri::XML::Document.parse(message.to_xml)
          order_details = document.css('OrderDetails')
          assert_equal 5, order_details.count
          assert_equal "GMJC100", order_details[0]['ItemNumber']
          assert_equal "GPM100", order_details[1]['ItemNumber']
          assert_equal "GBD100-3", order_details[2]['ItemNumber']
          assert_equal "GPST100 - 2", order_details[3]['ItemNumber']
        end

        it "explodes the line items into parts when applicable" do
          line_item_with_parts = LineItemDouble.example(part_line_items: [
              PartLineItemDouble.example(variant: VariantDouble.example(sku: "GBB200")),
              PartLineItemDouble.example(variant: VariantDouble.example(sku: "GSC300")),
              PartLineItemDouble.example(variant: VariantDouble.example(sku: "GML100"))
          ])
          order = OrderDouble.example(line_items: [
            line_item_with_parts,
            LineItemDouble.example
          ])
          shipment = ShipmentDouble.example(order: order)

          message = ShipmentOrder.new(:shipment => shipment, :client => @client)

          document = Nokogiri::XML::Document.parse(message.to_xml)
          order_details = document.css('OrderDetails')
          assert_equal 4, order_details.count
          assert_equal "GBB200", order_details[0]['ItemNumber']
          assert_equal "GSC300", order_details[1]['ItemNumber']
          assert_equal "GML100", order_details[2]['ItemNumber']
        end

        it "groups duplicate line items together" do
          phase_2 = LineItemDouble.example(part_line_items: [
              PartLineItemDouble.example(variant: VariantDouble.example(sku: "GBB200")),
              PartLineItemDouble.example(variant: VariantDouble.example(sku: "GSC300")),
              PartLineItemDouble.example(variant: VariantDouble.example(sku: "GML100"))
          ])
          order = OrderDouble.example(line_items: [
            phase_2,
            LineItemDouble.example(sku: "GBB200")
          ])
          shipment = ShipmentDouble.example(order: order)

          message = ShipmentOrder.new(:shipment => shipment, :client => @client)

          document = Nokogiri::XML::Document.parse(message.to_xml)
          order_details = document.css('OrderDetails')
          assert_equal 3, order_details.count
          assert_equal "GBB200", order_details[0]['ItemNumber']
          assert_equal "2", order_details[0]['QuantityOrdered']
          assert_equal "2", order_details[0]['QuantityToShip']
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

        def assert_line_item(expected_line_item, line_item)
          assert_equal expected_line_item.sku.to_s, line_item['ItemNumber']
          assert_equal expected_line_item.id.to_s, line_item['Line']
          assert_equal expected_line_item.quantity.to_s, line_item['QuantityOrdered']
          assert_equal expected_line_item.quantity.to_s, line_item['QuantityToShip']
          assert_equal "EA", line_item['UOM']
          assert_equal expected_line_item.price, line_item['Price']
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

      end
    end
  end
end
