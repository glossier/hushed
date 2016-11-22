require 'hushed/documents/response/shipment_order_result'
require 'hushed/documents/response/inventory_summary_document'
require 'hushed/documents/response/shipment_order_summary_result'


module Hushed
  module Response
    VALID_RESPONSE_TYPES = %w(ShipmentOrderResult InventorySummaryDocument ShipmentOrderInventory)

    def self.valid_type?(type)
      VALID_RESPONSE_TYPES.include?(type)
    end
  end
end
