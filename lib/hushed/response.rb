require 'hushed/documents/response/shipment_order_result'
require 'hushed/documents/response/inventory_summary_document'

module Hushed
  module Response
    VALID_RESPONSE_TYPES = %w(ShipmentOrderResult InventorySummaryDocument)

    def self.valid_type?(type)
      VALID_RESPONSE_TYPES.include?(type)
    end
  end
end
