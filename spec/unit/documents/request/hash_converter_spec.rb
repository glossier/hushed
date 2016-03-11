require 'spec_helper'
require 'hushed/documents/request/shipment_order'
require 'hushed/documents/request/hash_converter'

module Hushed
  module Documents
    module Request
      describe "ShipmentOrder" do
        include Hushed::Documents::Request::HashConverter

        it "uses the value from the parts if specified" do
          part = PartLineItemDouble.example(
            variant: VariantDouble.example(id: 1214, sku: "SKU42", price: 25.95),
            line_item: LineItemDouble.example(quantity: 3)
          )

          hash = part_line_item_hash(part)

          assert_equal "SKU42", hash['ItemNumber']
          assert_equal 1214, hash['Line']
          assert_equal 3, hash['QuantityOrdered']
          assert_equal 3, hash['QuantityToShip']
          assert_equal "EA", hash['UOM']
          assert_equal 25.95, hash['Price']
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
