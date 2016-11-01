require "forwardable"
require "hushed/documents/request/hash_converter"
require "hushed/black_tie_bundle"

module Hushed
  module Documents
    module Request
      class ShipmentOrder
        include Hushed::Documents::Document
        include Hushed::Documents::Request::HashConverter
        extend Forwardable

        NAMESPACE = "http://schemas.quietlogistics.com/V2/ShipmentOrder.xsd"

        DATEFORMAT = "%Y%m%d_%H%M%S"

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
            xml.ShipOrderDocument('xmlns' => 'http://schemas.quietlogistics.com/V2/ShipmentOrder.xsd') {

              xml.ClientID client_id
              xml.BusinessUnit business_unit

              xml.OrderHeader('OrderNumber' => @shipment_number,
                              'OrderType'   => order_type,
                              'OrderDate'   => @shipment.created_at.utc.iso8601,
                              'Gift'        => !!@shipment.order.gift) {

                xml.Extension @shipment.order.number

                if @shipment.order.gift
                  xml.Comments @shipment.order.gift.message
                end

                xml.ShipMode('Carrier'      => @shipment.shipping_method.carrier,
                             'ServiceLevel' => @shipment.shipping_method.service_level)

                xml.ShipTo(ship_to_hash)
                xml.BillTo(bill_to_hash)

                if @shipment.order.gift
                  xml.Notes('NoteType'   => 'GIFTFROM',
                                 'NoteValue'  => @shipment.order.gift.from)
                  xml.Notes('NoteType'   => 'GIFTTO',
                                 'NoteValue'  => @shipment.order.gift.to)
                end

                if @shipment.respond_to?(:value_added_services)
                  @shipment.value_added_services.each do |service|
                    xml.ValueAddedService('Service'     => service[:service],
                                          'ServiceType' => service[:service_type])
                  end
                end
              }

              add_items_to_shipment_order(@shipment.inventory_units_to_fulfill, xml)
            }
          end
          builder.to_xml
        end

        def add_items_to_shipment_order(items, xml)
          item_hashes = convert_to_hashes(items)
          grouped_items = group_items_by_sku(item_hashes)
          grouped_items.each_with_index do |hash, index|
            hash['Line'] = index + 1
            xml.OrderDetails(hash)
          end
        end

        def convert_to_hashes(items)
          converted_items = BlackTieBundle.convert(items)
          converted_items.map do |item|
            order_details(item)
          end.flatten
        end

        def group_items_by_sku(item_hashes)
          grouped = item_hashes.group_by {|hash| hash['ItemNumber'] }
          grouped.values.map do |hashes|
            hash = hashes.first
            update_quantity(hash, hashes.length)
          end
        end

        def update_quantity(hash, quantity)
          hash['QuantityOrdered'] = hash['QuantityToShip'] = quantity
          hash
        end

        def total_quantity(hashes)
          hashes.map{ |hash| hash['QuantityOrdered'] }.reduce(:+)
        end

        def order_type
          'SO'
        end

        def ship_address
          @shipment.address
        end

        def bill_address
          @shipment.order.bill_address
        end

        def full_name
          @shipment.address.full_name
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

        def message_id
          SecureRandom.uuid
        end

      end
    end
  end
end
