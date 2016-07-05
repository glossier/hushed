require 'spec_helper'
require 'hushed/documents/response/inventory_summary_document'

module Hushed
  module Documents
    module Response
      describe "InventorySummaryDocument" do
        include Fixtures

        it "should successfully parse an inventory summary document" do
          document = load_response('inventory_summary')
          inventory_summary = InventorySummaryDocument.new(io: document)
          inventory_items = inventory_summary.inventory_items

          assert_equal 'HUSHED', inventory_summary.client_id
          assert_equal '2016-06-22 19:36:21 UTC', inventory_summary.message_date.inspect
          assert_equal 'HUSHED', inventory_summary.business_unit
          assert_equal 'QUIET', inventory_summary.warehouse
          assert_equal ({"GBB100"=>"10000"}), inventory_summary.item_stat_hash(inventory_items[0])
        end

      end
    end
  end
end
