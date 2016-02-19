require 'spec_helper'
require 'hushed/documents/response/shipment_order_result'

module Hushed
  module Documents
    module Response
      describe "ShipmentOrderResult" do
        include Fixtures

        it "should be able to successfully parse a response document" do
          document = load_response('shipment_order_result')
          order_result = ShipmentOrderResult.new(io: document)

          assert_equal 'HUSHED', order_result.client_id
          assert_equal 'HUSHED', order_result.business_unit
          assert_equal 1, order_result.carton_count
          assert_equal Time.new(2009, 9, 1, 6, 0, 0).utc, order_result.date_shipped

          assert_equal "40000000000", order_result.tracking_number
          assert_equal "FIRST", order_result.service_level
          assert_equal "USPS", order_result.carrier
        end
      end
    end
  end
end
