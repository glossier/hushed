require 'spec_helper'
require 'hushed/back_to_reality_bundle'

module Hushed
  describe Hushed::BackToRealityBundle do

    it "checks if an item is Back to Reality bundle" do
      assert BackToRealityBundle.contained_in?([mask, headband, balm, other])
      refute BackToRealityBundle.contained_in?([other, other])
    end

    it "does not return a collection of individual parts included in the bundle" do
      items = BackToRealityBundle.convert([mask, headband, balm, other])

      item_skus = items.map { |item| item.variant.sku }
      assert_equal 2, item_skus.count
      assert_equal item_skus, ['ABC-123', 'GBTR']
    end

    it "supports multiple bundles" do
      items = BackToRealityBundle.convert([mask, headband, balm,
                                           mask, headband, balm,
                                           other])

      item_skus = items.map { |item| item.variant.sku }
      assert_equal 3, item_skus.count
      assert_equal item_skus.sort, ['ABC-123', 'GBTR', 'GBTR']
    end

    def mask
      InventoryUnitDouble.example(
        variant: VariantDouble.example(sku: "GMASK1-SET"),
        line_item: LineItemDouble.example(sku: "GBTR")
      )
    end

    def headband
      InventoryUnitDouble.example(
        variant: VariantDouble.example(sku: "headband1-SET"),
        line_item: LineItemDouble.example(sku: "GBTR")
      )
    end

    def balm
      InventoryUnitDouble.example(
        variant: VariantDouble.example(sku: "GBD300-SET"),
        line_item: LineItemDouble.example(sku: "GBTR")
      )
    end

    def other
      InventoryUnitDouble.example
    end

  end
end
