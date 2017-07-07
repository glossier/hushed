require 'spec_helper'
require 'hushed/documents/request/shipment_order'

module Hushed
  module Documents
    module Request
      describe 'ShipmentOrder' do
        before do
          @shipment = ShipmentDouble.example
          @order = @shipment.order
          @client = ClientDouble.new(client_id: 'HUSHED', business_unit: 'HUSHED', warehouse: 'SPACE')
          @object = @shipment_oddrder = ShipmentOrder.new(shipment: @shipment, client: @client)
          @xsd = Nokogiri::XML::Schema(File.read('spec/fixtures/documents/schemas/shipment_order.xsd'))
        end

        it "should raise an error if an shipment wasn't passed in" do
          assert_raises KeyError do
            ShipmentOrder.new(client: @client)
          end
        end

        it 'should be able to generate an XML document' do
          message = ShipmentOrder.new(shipment: @shipment, client: @client)
          document = Nokogiri::XML::Document.parse(message.to_xml)

          expected_namespaces = { 'xmlns' => ShipmentOrder::NAMESPACE }
          assert_equal expected_namespaces, document.collect_namespaces

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
          message = ShipmentOrder.new(shipment: @shipment, client: @client)
          document = Nokogiri::XML::Document.parse(message.to_xml)

          assert_equal 'true', document.css('OrderHeader')[0]['Gift']
          assert_equal 'GIFTFROM', document.css('Notes')[0]['NoteType']
          assert_equal 'from', document.css('Notes')[0]['NoteValue']
          assert_equal 'GIFTTO', document.css('Notes')[1]['NoteType']
          assert_equal 'to', document.css('Notes')[1]['NoteValue']
          assert_equal 'HBD', document.css('Comments')[0].text
        end

        it "the XML document should not have the associated gift attributes set if the order's gift exists" do
          message = ShipmentOrder.new(shipment: ShipmentDouble.example(order: OrderDouble.example(gift: nil)), client: @client)
          document = Nokogiri::XML::Document.parse(message.to_xml)

          assert_equal 'false', document.css('OrderHeader')[0]['Gift']
          assert_empty document.css('SONoteType')
          assert_empty document.css('Comments')
        end

        it 'uses a sequence as the Line attribute of the OrderDetails' do
          shipment = ShipmentDouble.example(inventory_units_to_fulfill: [
                                              InventoryUnitDouble.example(variant: VariantDouble.example(sku: 'SKU-1')),
                                              InventoryUnitDouble.example(variant: VariantDouble.example(sku: 'SKU-2')),
                                              InventoryUnitDouble.example(variant: VariantDouble.example(sku: 'SKU-3'))
                                            ])

          message = ShipmentOrder.new(shipment: shipment, client: @client)

          order_details = order_details_from(message)
          assert_equal '1', order_details[0]['Line']
          assert_equal '2', order_details[1]['Line']
          assert_equal '3', order_details[2]['Line']
        end

        it 'explodes the line items into parts when applicable' do
          shipment = ShipmentDouble.example(inventory_units_to_fulfill: [
                                              InventoryUnitDouble.example(variant: VariantDouble.example(sku: 'GBB200')),
                                              InventoryUnitDouble.example(variant: VariantDouble.example(sku: 'GSC300')),
                                              InventoryUnitDouble.example(variant: VariantDouble.example(sku: 'GML100')),
                                              InventoryUnitDouble.example
                                            ])

          message = ShipmentOrder.new(shipment: shipment, client: @client)

          order_details = order_details_from(message)
          assert_equal 4, order_details.count
          order_details.each { |details| assert_equal '1', details['QuantityOrdered'] }
          assert_equal 'GBB200', order_details[0]['ItemNumber']
          assert_equal 'GSC300', order_details[1]['ItemNumber']
          assert_equal 'GML100', order_details[2]['ItemNumber']
        end

        it 'groups duplicate line items together' do
          shipment = ShipmentDouble.example(inventory_units_to_fulfill: [
                                              InventoryUnitDouble.example(variant: VariantDouble.example(sku: 'GBB200')),
                                              InventoryUnitDouble.example(variant: VariantDouble.example(sku: 'GBB200')),
                                              InventoryUnitDouble.example(variant: VariantDouble.example(sku: 'GSC300')),
                                              InventoryUnitDouble.example(variant: VariantDouble.example(sku: 'GSC300')),
                                              InventoryUnitDouble.example(variant: VariantDouble.example(sku: 'GML100')),
                                              InventoryUnitDouble.example(variant: VariantDouble.example(sku: 'GBB200'))
                                            ])

          message = ShipmentOrder.new(shipment: shipment, client: @client)

          order_details = order_details_from(message)
          assert_equal 3, order_details.count
          assert_equal 'GBB200', order_details[0]['ItemNumber']
          assert_equal '3', order_details[0]['QuantityOrdered']
          assert_equal '3', order_details[0]['QuantityToShip']
        end

        it 'lists the packaging instructions if shipment.value_added_service exists' do
          shipment = ShipmentDouble.example(value_added_services: [{ service: 'bagging', service_type: 'phase 1 set' }])

          message = ShipmentOrder.new(shipment: shipment, client: @client)
          document = Nokogiri::XML::Document.parse(message.to_xml)

          assert_equal 'bagging', document.css('OrderHeader ValueAddedService')[0]['Service']
          assert_equal 'phase 1 set', document.css('OrderHeader ValueAddedService')[0]['ServiceType']
        end

        it 'is valid against the xml schema definition' do
          shipment = ShipmentDouble.example

          message = ShipmentOrder.new(shipment: shipment, client: @client)
          document = Nokogiri::XML::Document.parse(message.to_xml)

          assert_empty @xsd.validate(document)
        end

        it 'adds an item capture attribute for gift card' do
          gift_card = ProductDouble.example(gift_card: true)
          shipment = ShipmentDouble.example(inventory_units_to_fulfill: [
                                              InventoryUnitDouble.example(variant: VariantDouble.example(product: gift_card))
                                            ])

          message = ShipmentOrder.new(shipment: shipment, client: @client)
          document = Nokogiri::XML::Document.parse(message.to_xml)

          gift_card = document.css('OrderDetails').first
          assert_equal 'true', gift_card['ItemIDCapture']
        end

        it 'sends gift card as separate order details' do
          gift_card = ProductDouble.example(gift_card: true)
          shipment = ShipmentDouble.example(inventory_units_to_fulfill: [
                                              InventoryUnitDouble.example(variant: VariantDouble.example(product: gift_card, sku: 'GGFC-01-2500')),
                                              InventoryUnitDouble.example(variant: VariantDouble.example(sku: 'GML200')),
                                              InventoryUnitDouble.example(variant: VariantDouble.example(product: gift_card, sku: 'GGFC-01-2500'))
                                            ])

          message = ShipmentOrder.new(shipment: shipment, client: @client)

          order_details = order_details_from(message)
          assert_equal 3, order_details.count
          assert_equal 'GML200', order_details[0]['ItemNumber']
          assert_equal '1', order_details[0]['QuantityOrdered']
          assert_equal '1', order_details[0]['QuantityToShip']
          assert_equal 'GGFC-01-2500', order_details[1]['ItemNumber']
          assert_equal '1', order_details[1]['QuantityOrdered']
          assert_equal '1', order_details[1]['QuantityToShip']
          assert_equal 'GGFC-01-2500', order_details[1]['ItemNumber']
          assert_equal '1', order_details[1]['QuantityOrdered']
          assert_equal '1', order_details[1]['QuantityToShip']
        end

        it 'includes the recipient and purchaser names in the request' do
          gift_card = LineItemDouble.example(gift_cards: [
                                               VirtualGiftCardDouble.example(purchaser_name: 'Tarzan', recipient_name: 'Jane')
                                             ])
          shipment = ShipmentDouble.example(inventory_units_to_fulfill: [
                                              InventoryUnitDouble.example(variant: VariantDouble.example(sku: 'GML200')),
                                              InventoryUnitDouble.example(variant: VariantDouble.example(sku: 'GC-50'), line_item: gift_card)
                                            ])

          message = ShipmentOrder.new(shipment: shipment, client: @client)
          document = Nokogiri::XML(message.to_xml).remove_namespaces!

          gift_card_info = document.xpath('/ShipOrderDocument/OrderDetails[2]/ValueAddedService').first
          refute_nil gift_card_info
          assert_equal 'GIFTCARD', gift_card_info['ServiceType']
          assert_equal 'FROM: Tarzan TO: Jane', gift_card_info['Service']
        end

        it 'ignores null phone number' do
          address_without_phone = AddressDouble.example(phone: nil)
          shipment = ShipmentDouble.example(order: OrderDouble.example(ship_address: address_without_phone))

          message = ShipmentOrder.new(shipment: shipment, client: @client)
          document = Nokogiri::XML::Document.parse(message.to_xml)

          address = document.css('ShipTo').first
          assert_nil address['Phone']
        end

        it 'sends the localized price' do
          shipment = ShipmentDouble.example(inventory_units_to_fulfill: [
            InventoryUnitDouble.example(
              variant: VariantDouble.example(
                prices: {
                  'USD' => MoneyDouble.example(cents: 1000),
                  'CAD' => MoneyDouble.example(cents: 1500)
                }
              ),
              order: OrderDouble.example(currency: 'CAD')
            )
          ])
          message = ShipmentOrder.new(shipment: shipment, client: @client)

          order_details = order_details_from(message)

          assert_equal('15.0', order_details.first['Price'])
        end

      private

        def assert_header(header)
          assert_equal @shipment.number.to_s, header['OrderNumber']
          assert_equal @shipment.created_at.utc.iso8601.to_s, header['OrderDate']
          assert_equal @order.type, header['OrderType']
        end

        def assert_shipping(shipping)
          assert_equal 'FEDEX', shipping['Carrier']
          assert_equal 'GROUND', shipping['ServiceLevel']
        end

        def assert_order_details(expected, actual)
          assert_equal expected.variant.sku.to_s, actual['ItemNumber']
          assert_equal '1', actual['Line']
          assert_equal '1', actual['QuantityOrdered']
          assert_equal '1', actual['QuantityToShip']
          assert_equal 'EA', actual['UOM']
          assert_equal '10.0', actual['Price']
          assert_nil actual['ItemIDCapture']
        end

        def assert_address(_email, address, node)
          assert_equal address.company, node['Company']
          assert_equal address.name, node['Contact']
          assert_equal address.address1, node['Address1']
          assert_equal address.address2, node['Address2']
          assert_equal address.city, node['City']
          assert_equal address.state.name, node['State']
          assert_equal address.zipcode, node['PostalCode']
          assert_equal address.country.name, node['Country']
          assert_equal address.phone, node['Phone']
        end

        def order_details_from(message)
          document = Nokogiri::XML::Document.parse(message.to_xml)
          document.css('OrderDetails')
        end
      end
    end
  end
end
