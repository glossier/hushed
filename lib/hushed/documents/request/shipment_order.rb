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

              xml.ClientID @client.client_id
              xml.BusinessUnit @client.business_unit

              xml.OrderHeader('OrderNumber' => @shipment_number,
                              'OrderType'   => order_type,
                              'OrderDate'   => @shipment.created_at.utc) {

                xml.Extension @shipment.order.number

                xml.Comments @shipment.order.special_instructions

                xml.ShipMode('Carrier'      => shipping_method,
                             'ServiceLevel' => service_level)

                xml.ShipTo(ship_to_hash)
                xml.BillTo(bill_to_hash)

                # xml.Notes('NoteType' => @shipment['note_type'].to_s, 'NoteValue' => @shipment['note_value'].to_s)
              }

              order_items.collect do |item|
                xml.OrderDetails(line_item_hash(item))
              end
            }
          end
          builder.to_xml
        end

        def order_items
          @shipment.order.line_items
        end

        def shipping_method
          value = @shipment.shipping_method.try(:code)
          value = @shipment.shipping_method.try(:code) if value.blank?
          value
        end

        # NOTE: We may want to introduce a new field here
        def service_level
          value = @shipment.shipping_method.try(:admin_name)
          value = @shipment.shipping_method.try(:admin_name) if value.blank?
          value
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

        # def initialize(options = {})
        #   @shipment        = options[:shipment] || raise(MissingOrderError.new("order cannot be missing"))
        #   @client          = options[:client] || raise(MissingClientError.new("client cannot be missing"))
        #   @shipment_number = @shipment.number
        #   @name            = "@business_unit_ShipmentOrder_#{@shipment_number}_#{date_stamp}.xml"
        # end
        #
        # def to_xml
        #   builder = Nokogiri::XML::Builder.new do |xml|
        #     xml.ShipOrderDocument('xmlns' => 'http://schemas.quietlogistics.com/V2/ShipmentOrder.xsd') {
        #
        #       xml.ClientID @config['client_id']
        #       xml.BusinessUnit @config['business_unit']
        #
        #       xml.OrderHeader('OrderNumber' => @shipment_number,
        #                       'OrderType'   => @shipment['order_type'],
        #                       'OrderDate'   => DateTime.now.iso8601) {
        #
        #         xml.Extension shipment['order_number']
        #
        #         xml.Comments shipment['comments'].to_s
        #
        #         xml.ShipMode('Carrier'      => @shipment['carrier'],
        #                      'ServiceLevel' => @shipment['service_level'])
        #
        #         xml.ShipTo(ship_to_hash)
        #         xml.BillTo(bill_to_hash)
        #
        #         xml.Notes('NoteType' => @shipment['note_type'].to_s, 'NoteValue' => @shipment['note_value'].to_s)
        #       }
        #
        #       @shipment['items'].collect do |item|
        #         xml.OrderDetails(line_item_hash(item))
        #       end
        #     }
        #   end
        #   builder.to_xml
        # end
        #
        # def type
        #   'ShipmentOrder'
        # end
        #
        # def line_item_hash(item)
        #   {
        #     'ItemNumber'      => item["sku"],
        #     'Line'            => item['line_number'],
        #     'QuantityOrdered' => item['quantity'],
        #     'QuantityToShip'  => item['quantity'],
        #     'UOM'             => 'EA',
        #     'Price'           => item['price']
        #   }
        # end
        #
        # def ship_to_hash
        #   {
        #     'Company'    => full_name,
        #     'Contact'    => @shipment['shipping_address']['contact'],
        #     'Address1'   => @shipment['shipping_address']['address1'],
        #     'Address2'   => @shipment['shipping_address']['address2'],
        #     'City'       => @shipment['shipping_address']['city'],
        #     'State'      => @shipment['shipping_address']['state'],
        #     'PostalCode' => @shipment['shipping_address']['zipcode'],
        #     'Country'    => @shipment['shipping_address']['country']
        #   }
        # end
        #
        # def bill_to_hash
        #   {
        #     'Company'    => full_name,
        #     'Contact'    => @shipment['billing_address']['contact'],
        #     'Address1'   => @shipment['billing_address']['address1'],
        #     'Address2'   => @shipment['billing_address']['address2'],
        #     'City'       => @shipment['billing_address']['city'],
        #     'State'      => @shipment['billing_address']['state'],
        #     'PostalCode' => @shipment['billing_address']['zipcode'],
        #     'Country'    => @shipment['billing_address']['country']
        #   }
        # end
        #
        # def full_name
        #   "#{shipment['shipping_address']['firstname']} #{@shipment['shipping_address']['lastname']}"
        # end
        #
        # def message
        #   "Succesfully Sent Shipment #{@shipment_number} to Quiet Logistics"
        # end
        #
        # def date_stamp
        #   Time.now.strftime('%Y%m%d_%H%M%3N')
        # end

      end
    end
  end
end
