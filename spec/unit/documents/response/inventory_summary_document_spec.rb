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

          expect(inventory_summary.client_id).to eq('HUSHED')
          expect(inventory_summary.message_date.inspect).to eq('2016-06-22 19:36:21 UTC')
          expect(inventory_summary.business_unit).to eq('HUSHED')
          expect(inventory_summary.warehouse).to eq('QUIET')

          expect(inventory_summary.item_stat_hash(inventory_items[0])).to eq({ "GBB100" => "10000" })
        end

      end
    end
  end
end
