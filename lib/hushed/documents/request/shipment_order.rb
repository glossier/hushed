require 'forwardable'

module Hushed
  module Documents
    module Request
      class ShipmentOrder
        include Hushed::Documents::Document
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
                              'OrderDate'   => @shipment.created_at.utc.iso8601) {

                xml.Extension @shipment.order.number

                xml.Comments @shipment.order.special_instructions

                xml.ShipMode('Carrier'      => @shipment.shipping_method.carrier,
                             'ServiceLevel' => @shipment.shipping_method.service_level)

                xml.ShipTo(ship_to_hash)
                xml.BillTo(bill_to_hash)

                if @shipment.respond_to?(:value_added_services)
                  @shipment.value_added_services.collect do |service|
                    xml.ValueAddedService('Service'     => service[:service],
                                          'ServiceType' => service[:service_type])
                  end
                end
              }

              order_items.collect do |item|
                if Phase1Set.match(item)
                  add_individual_phase_1_items(item, xml)
                else
                  xml.OrderDetails(line_item_hash(item))
                end
              end
            }
          end
          builder.to_xml
        end

        def add_individual_phase_1_items(phase_1_item, xml)
          phase_1 = Phase1Set.new(phase_1_item).included_items
          phase_1.collect do |item|
            xml.OrderDetails(line_item_hash(item))
          end
        end

        def order_items
          @shipment.order.line_items.select do |item|
            if item.product.respond_to?(:restricted?)
              !item.product.restricted?
            else
              true
            end
          end
        end

        def order_type
          'SO'
        end

        def line_item_hash(item)
          {
            'ItemNumber'      => item.sku,
            'Line'            => item.id,
            'QuantityOrdered' => item.quantity,
            'QuantityToShip'  => item.quantity,
            'UOM'             => 'EA',
            'Price'           => item.price
          }
        end

        def ship_to_hash
          {
            'Company'    => ship_address.company,
            'Contact'    => full_name,
            'Address1'   => ship_address.address1,
            'Address2'   => ship_address.address2,
            'City'       => ship_address.city,
            'State'      => ship_address.state.name,
            'PostalCode' => ship_address.zipcode,
            'Country'    => ship_address.country.name
          }
        end

        def bill_to_hash
          {
            'Company'    => bill_address.company,
            'Contact'    => full_name,
            'Address1'   => bill_address.address1,
            'Address2'   => bill_address.address2,
            'City'       => bill_address.city,
            'State'      => bill_address.state.name,
            'PostalCode' => bill_address.zipcode,
            'Country'    => bill_address.country.name
          }
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
