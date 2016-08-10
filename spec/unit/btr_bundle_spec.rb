require 'spec_helper'
require 'hushed/btr_bundle'

module Hushed
  describe "Hushed::BtrBundle" do

    it "checks if an item is Back to Reality bundle" do
      assert BtrBundle.match(inventory_unit("GBTR"))
      refute BtrBundle.match(inventory_unit("any-other-sku"))
    end

    it "does not return a collection of individual parts included in the bundle" do
      btr_bundle = BtrBundle.new(inventory_unit("GBTR", 4))
      items = btr_bundle.included_items

      assert_equal 1, items.count
      assert_includes items.map(&:sku), 'GBTR'
    end

    def inventory_unit(sku, quantity = 1)
      InventoryUnitDouble.example(
          variant: VariantDouble.example(sku: sku)
      )
    end

    def btr_bundle
      InventoryUnit.new("GBTR", 10.0)
    end

  end
end
