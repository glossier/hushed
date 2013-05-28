require 'hushed/documents/response/shipment_order_result'

module Hushed
  module Response
    VALID_RESPONSE_TYPES = %w(ShipmentOrderResult)

    def self.valid_type?(type)
      VALID_RESPONSE_TYPES.include?(type)
    end
  end
end