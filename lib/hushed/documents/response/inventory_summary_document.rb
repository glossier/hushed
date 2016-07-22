module Hushed
  module Documents
    module Response
      class InventorySummaryDocument

        def initialize(options = {})
          @io = options[:io]
          @document = Nokogiri::XML::Document.parse(@io)
        end

        def client_id
          @client_id ||= inventory_summary['ClientId']
        end

        def message_date
          @message_date ||= Time.parse(inventory_summary['MessageDate'])
        end

        def business_unit
          @business_unit ||= inventory_summary['BusinessUnit']
        end

        def warehouse
          @warehouse ||= inventory_summary['Warehouse']
        end

        def quantity_by_status(item)
          item_quantity_by_status = {}
          available_item = get_available_status(item)
          sku = item['ItemNumber']
          item_quantity_by_status[sku] = get_available_status(item)['Quantity']
          item_quantity_by_status
        end

        def inventory_items
          @items ||= @document.css('Inventory')
        end

        def inventory_summary
          @inventory_summary ||= @document.css('InventorySummary').first
        end

        def get_available_status(item)
          for item_status in item.css('ItemStatus')
            return item_status if item_status['Status'] == "Avail"
          end
        end

      end
    end
  end
end
