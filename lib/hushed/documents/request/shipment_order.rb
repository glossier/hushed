module Hushed
  module Documents
    module Request
      class ShipmentOrder

        NAMESPACE = "http://schemas.quietlogistics.com/V2/ShipmentOrder.xsd"

        DATEFORMAT = "%Y%m%d_%H%M%S"

        class MissingOrderError < StandardError; end
        class MissingClientError < StandardError; end

        attr_reader :order, :client

        def initialize(options = {})
          @order = options[:order] || raise(MissingOrderError.new("order cannot be missing"))
          @client = options[:client] || raise(MissingClientError.new("client cannot be missing"))
        end

        def to_xml
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.ShipOrderDocument(xmlns: NAMESPACE) do
              xml.ClientID @client.client_id
              xml.BusinessUnit @client.business_unit
              xml.OrderHeader(order_header_attributes) do
                xml.Comments @order.note
                xml.ShipMode(shipping_attributes(@order.shipping_lines.first))
                xml.ShipTo(address_attributes(@order.shipping_address))
                xml.BillTo(address_attributes(@order.billing_address))
                xml.DeclaredValue @order.total_price
                @order.line_items.each.with_index(1) do |line_item, index|
                  xml.OrderDetails(line_item_attributes(line_item, index))
                end
              end
            end
          end
          builder.to_xml
        end

        def type
          'ShipmentOrder'
        end

        def document_number
          @order.id
        end

        def order_type
          'SO'
        end

        def date
          @order.created_at.utc
        end

        def filename
          "#{@client.business_unit}_#{type}_#{document_number}_#{date.strftime(DATEFORMAT)}.xml"
        end

        def order_header_attributes
          {OrderNumber: document_number, OrderType: order_type, OrderDate: date, ShipDate: date}
        end

        def shipping_attributes(shipping_line)
          {Carrier: shipping_line.carrier, ServiceLevel: shipping_line.service_level}
        end

        def address_attributes(address)
          {
            Company: address.company, Contact: address.name, Address1: address.address1, Address2: address.address2,
            City: address.city, State: address.province_code, PostalCode: address.zip, Country: address.country_code,
            Email: @order.email
          }
        end

        def line_item_attributes(line_item, line_number)
          {
            ItemNumber: line_item.id, Line: line_number, QuantityOrdered: line_item.quantity,
            QuantityToShip: line_item.quantity, UOM: line_item.unit_of_measure, Price: line_item.price
          }
        end
      end
    end
  end
end