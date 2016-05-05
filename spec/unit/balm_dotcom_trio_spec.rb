require 'spec_helper'
require 'hushed/balm_dotcom_trio'

module Hushed
  describe "Hushed::BalmDotcomTrio" do

    it "checks if an item is Balm Dotcom trio" do
      assert BalmDotcomTrio.match(line_item("GBDT"))
      refute BalmDotcomTrio.match(line_item("any-other-sku"))
    end

    it "returns a collection of individual balms included in the trio" do
      balm_dotcom_trio = BalmDotcomTrio.new(line_item("GBDT", 4))
      items = balm_dotcom_trio.included_items

      assert_equal 3, items.count
      assert_includes_all items, [ mint_balm, cherry_balm, rose_balm ]
    end

    def assert_includes_all(collection, expected)
      expected.each { |item| assert_includes collection, item }
    end

    def line_item(sku, quantity = 1)
      LineItemDouble.example(sku: sku, quantity: quantity)
    end

    def mint_balm
      LineItem.new("GBD300", 4, 12.0)
    end

    def cherry_balm
      LineItem.new("GBD400", 4, 12.0)
    end

    def rose_balm
      LineItem.new("GBD500", 4, 12.0)
    end
  end
end
