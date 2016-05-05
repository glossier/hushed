require 'spec_helper'
require 'hushed/documents/request/shipment_order'
require 'hushed/documents/request/hash_converter'

module Hushed
  module Documents
    module Request
      describe "ShipmentOrder" do
        include Hushed::Documents::Request::HashConverter

        it "serializes the line item parts into a hash" do
          part = PartLineItemDouble.example(
            variant: VariantDouble.example(id: 1214, sku: "SKU42", price: 25.95),
            line_item: LineItemDouble.example(quantity: 3)
          )

          hash = part_line_item_hash(part)

          assert_equal "SKU42", hash['ItemNumber']
          assert_equal 3, hash['QuantityOrdered']
          assert_equal 3, hash['QuantityToShip']
          assert_equal "EA", hash['UOM']
          assert_equal 25.95, hash['Price']
        end

        it "serializes the line item into a hash" do
          item = LineItemDouble.example

          hash = line_item_hash(item)

          assert_equal item.sku, hash['ItemNumber']
          assert_equal item.quantity, hash['QuantityOrdered']
          assert_equal item.quantity, hash['QuantityToShip']
          assert_equal "EA", hash['UOM']
          assert_equal item.price, hash['Price']
        end

        it "strip the postfix '-SET' from the sku" do
          item = LineItemDouble.example(sku: "ABC-SET")

          assert_equal "ABC", line_item_hash(item)['ItemNumber']
        end

        it "strip the postfix '-SET' from the sku" do
          part = PartLineItemDouble.example(
            variant: VariantDouble.example(sku: "ABC-SET")
          )

          assert_equal "ABC", part_line_item_hash(part)['ItemNumber']
        end
      end
    end
  end
end
