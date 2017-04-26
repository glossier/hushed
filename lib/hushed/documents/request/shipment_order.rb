require 'forwardable'
require 'hushed/documents/request/hash_converter'
require 'hushed/black_tie_bundle'

module Hushed
  module Documents
    module Request
      class ShipmentOrder
        include Hushed::Documents::Document
        include Hushed::Documents::Request::HashConverter
        extend Forwardable

        NAMESPACE = 'http://schemas.quietlogistics.com/V2/ShipmentOrder.xsd'.freeze

        class MissingOrderError < StandardError; end
        class MissingClientError < StandardError; end

        attr_reader :shipment, :client

        def_delegators :@client, :warehouse, :business_unit, :client_id

        def initialize(options = {})
          @client   = options.fetch(:client)
          @shipment = options.fetch(:shipment)
          @shipment_number = @shipment.number
        end

        def to_xml
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.ShipOrderDocument('xmlns' => 'http://schemas.quietlogistics.com/V2/ShipmentOrder.xsd') do
              xml.ClientID client_id
              xml.BusinessUnit business_unit

              xml.OrderHeader('OrderNumber' => @shipment_number,
                              'OrderType'   => order_type,
                              'OrderDate'   => @shipment.created_at.utc.iso8601,
                              'Gift'        => gift_message?) do

                xml.Extension @shipment.order.number

                if @shipment.order.gift
                  xml.Comments @shipment.order.gift.message
                end

                carrier       = @shipment.carrier || @shipment.shipping_method.carrier
                service_level = @shipment.service_level || @shipment.shipping_method.service_level

                xml.ShipMode('Carrier'      => carrier,
                             'ServiceLevel' => service_level)

                xml.ShipTo(ship_to_hash)
                xml.BillTo(bill_to_hash)

                if gift_message?
                  xml.Notes('NoteType'   => 'GIFTFROM',
                            'NoteValue'  => gift.from)
                  xml.Notes('NoteType'   => 'GIFTTO',
                            'NoteValue'  => gift.to)
                end

                if @shipment.respond_to?(:value_added_services)
                  @shipment.value_added_services.each do |service|
                    xml.ValueAddedService('Service'     => service[:service],
                                          'ServiceType' => service[:service_type])
                  end
                end
              end

              add_items_to_shipment_order(@shipment.inventory_units_to_fulfill, xml)
            end
          end
          builder.to_xml
        end

        def add_items_to_shipment_order(items, xml)
          item_hashes = convert_to_hashes(items)
          grouped_items = group_items_by_sku(item_hashes)

          grouped_items.each_with_index do |hash, index|
            hash['Line'] = index + 1
            xml.OrderDetails(hash) do
              gift_card = gift_card_for(hash['ItemNumber'], items)
              add_gift_card_info(gift_card, xml) if gift_card
            end
          end
        end

        def gift_card_for(sku, items)
          item = items.find { |i| Hushed::Sku.extract_and_normalize(i.variant) == sku }
          return if item.nil? || item.line_item.nil?
          item.line_item.gift_cards.first
        end

        def add_gift_card_info(gift_card, xml)
          service = "FROM: #{gift_card.purchaser_name} TO: #{gift_card.recipient_name}"
          xml.ValueAddedService('Service'     => service,
                                'ServiceType' => 'GIFTCARD')
        end

        def convert_to_hashes(items)
          converted_items = BlackTieBundle.convert(items)
          converted_items.map do |item|
            order_details(item)
          end.flatten
        end

        def group_items_by_sku(item_hashes)
          giftcards_and_others = item_hashes.partition { |hash| !hash['ItemIDCapture'].nil? }
          others = giftcards_and_others[1].group_by { |hash| hash['ItemNumber'] }.values.map do |hashes|
            hash = hashes.first
            update_quantity(hash, hashes.length)
          end
          giftcards = giftcards_and_others[0].map { |hash| update_quantity(hash, 1) }
          others.concat(giftcards)
        end

        def update_quantity(hash, quantity)
          hash['QuantityOrdered'] = hash['QuantityToShip'] = quantity
          hash
        end

        def total_quantity(hashes)
          hashes.map { |hash| hash['QuantityOrdered'] }.reduce(:+)
        end

        def order_type
          'SO'
        end

        def ship_address
          @shipment.order.ship_address
        end

        def bill_address
          @shipment.order.bill_address
        end

        def full_name
          @shipment.order.ship_address.full_name
        end

        def message
          "Succesfully Sent Shipment #{@shipment_number} to Quiet Logistics"
        end

        def date_stamp
          Time.now.strftime('%Y%m%d_%H%M%3N')
        end

        def type
          'ShipmentOrder'
        end

        def document_number
          @shipment_number
        end

        def date
          @shipment.created_at
        end

        def filename
          "#{business_unit}_#{type}_#{document_number}_#{date.strftime(DATEFORMAT)}.xml"
        end

        def gift_message?
          gift && gift.active?
        end

        def gift
          @gift ||= shipment.order.gift
        end
      end
    end
  end
end
