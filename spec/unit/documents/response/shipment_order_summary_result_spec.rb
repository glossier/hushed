require 'spec_helper'
require 'hushed/documents/response/shipment_order_summary_result'

module Hushed
  module Documents
    module Response
      describe "ShipmentOrderResult" do
        include Fixtures

        it "should be able to successfully parse a response document" do
          document = load_response('shipment_order_summary_result')
          order_summary_result = ShipmentOrderSummaryResult.new(io: document)

          assert_equal 'CLIENT', order_summary_result.client_id
          assert_equal 'BUSINESS', order_summary_result.business_unit
          assert_equal 'WAREHOUSE', order_summary_result.warehouse
          assert_equal Time.new(1976, 3, 10, 0, 0, 0).utc, order_summary_result.from_date
          assert_equal Time.new(1992, 12, 15, 0, 0, 0).utc, order_summary_result.to_date
          
          assert_equal :new, order_summary_result.statuses['H62003013021']
          assert_equal :shipped, order_summary_result.statuses['H62003013038']
          assert_equal :cancelled, order_summary_result.statuses['H83538851711']
          assert_equal :open, order_summary_result.statuses['H00221376533']
        end
      end
    end
  end
end
