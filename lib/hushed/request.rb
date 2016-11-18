require 'hushed/documents/request/shipment_order'
require 'hushed/documents/request/shipment_order_summary'

module Hushed
  module Request
    VALID_REQUEST_TYPES = %w(ShipmentOrder ShipmentOrderSummaryRequest)

    def self.valid_type?(type)
      VALID_REQUEST_TYPES.include?(type)
    end
  end
end
