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

        def item_stat_hash(item)
          item_stat = {}
          available_item = get_available_stat(item)
          sku = item['ItemNumber']
          item_stat[sku] = get_available_stat(item)['Quantity']
          item_stat
        end

        def inventory_items
          @items ||= @document.css('Inventory')
        end

        def inventory_summary
          @inventory_summary ||= @document.css('InventorySummary').first
        end

        def get_available_stat(item)
          for item_stat in item.css('ItemStatus')
            return item_stat if item_stat['Status'] == "Avail"
          end
        end

      end
    end
  end
end
