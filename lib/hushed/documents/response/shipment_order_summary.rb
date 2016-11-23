module Hushed
  module Documents
    module Response
      class ShipmentOrderSummary
        attr_reader :io

        def initialize(options = {})
          @io = options[:io]
          @document = Nokogiri::XML::Document.parse(@io)
        end

        def client_id
          @client_id ||= shipment_order_summary['ClientId']
        end

        def business_unit
          @business_unit ||= shipment_order_summary['BusinessUnit']
        end

        def warehouse
          @warehouse ||= shipment_order_summary['Warehouse']
        end

        def from_date
          @from_date ||= Time.parse(shipment_order_summary['FromDate']).utc
        end

        def to_date
          @to_date ||= Time.parse(shipment_order_summary['ToDate']).utc
        end

        def statuses
          @statuses ||= begin
            statuses = {}
            add_orders_status(statuses, 'NewOrders', :new)
            add_orders_status(statuses, 'ShippedOrders', :shipped)
            add_orders_status(statuses, 'CancelledOrders', :cancelled)
            add_orders_status(statuses, 'OpenOrders', :open)
            statuses
          end
        end

        def shipment_order_summary
          @shipment_order_summary ||= @document.css('ShipmentOrderSummary').first
        end

        private

        def add_orders_status(statuses, node, status)
          status_node = shipment_order_summary.css(node)
          return unless status_node.any?

          status_node.first.css('Order').each { |o| statuses[o['OrderNumber']] = status }
        end
      end
    end
  end
end
