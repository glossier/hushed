require 'spec_helper'
require 'hushed/balm_dotcom_trio'

module Hushed
  describe "Hushed::BalmDotcomTrio" do

    it "checks if an item is Balm Dotcom trio" do
      assert BalmDotcomTrio.match(inventory_unit("GBDT"))
      refute BalmDotcomTrio.match(inventory_unit("any-other-sku"))
    end

    it "returns a collection of individual balms included in the trio" do
      balm_dotcom_trio = BalmDotcomTrio.new(inventory_unit("GBDT", 4))
      items = balm_dotcom_trio.included_items

      assert_equal 3, items.count
      assert_includes_all items, [ mint_balm, cherry_balm, rose_balm ]
    end

    def assert_includes_all(collection, expected)
      expected.each { |item| assert_includes collection, item }
    end

    def inventory_unit(sku, quantity = 1)
      InventoryUnitDouble.example(
          variant: VariantDouble.example(sku: sku)
      )
    end

    def mint_balm
      InventoryUnit.new("GBD300", 10.0)
    end

    def cherry_balm
      InventoryUnit.new("GBD400", 10.0)
    end

    def rose_balm
      InventoryUnit.new("GBD500", 10.0)
    end
  end
end
