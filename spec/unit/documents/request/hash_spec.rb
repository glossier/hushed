require 'spec_helper'
require 'hushed/documents/request/shipment_order'

module Hushed
  module Documents
    module Request
      describe "ShipmentOrder" do
        include Hushed::Documents::Request::Hash

        it "uses the value from the parts if specified" do
          item = LineItemDouble.example(quantity: 3)
          part = VariantDouble.example

          hash = line_item_hash(item, part)

          assert_equal part.sku, hash['ItemNumber']
          assert_equal part.id, hash['Line']
          assert_equal item.quantity, hash['QuantityOrdered']
          assert_equal item.quantity, hash['QuantityToShip']
          assert_equal "EA", hash['UOM']
          assert_equal part.price, hash['Price']
        end

        it "defaults to the item values when the item does not contain parts" do
          item = LineItemDouble.example

          hash = line_item_hash(item)

          assert_equal item.sku, hash['ItemNumber']
          assert_equal item.id, hash['Line']
          assert_equal item.quantity, hash['QuantityOrdered']
          assert_equal item.quantity, hash['QuantityToShip']
          assert_equal "EA", hash['UOM']
          assert_equal item.price, hash['Price']
        end
      end
    end
  end
end
