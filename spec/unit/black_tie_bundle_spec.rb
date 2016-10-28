require 'spec_helper'
require 'hushed/black_tie_bundle'

module Hushed
  describe Hushed::BlackTieBundle do

    it "does not return a collection of individual parts included in the bundle" do
      items = BlackTieBundle.convert([pencil, nail_polish, haloscope, lip_gloss, other])

      item_skus = items.map { |item| item.variant.sku }
      assert_equal 2, item_skus.count
      assert_equal item_skus, ['ABC-123', 'GHOL-16-1001']
    end

    it "supports multiple bundles" do
      items = BlackTieBundle.convert([pencil, nail_polish, haloscope, lip_gloss,
                                      pencil, nail_polish, haloscope, lip_gloss,
                                      other])

      item_skus = items.map { |item| item.variant.sku }
      assert_equal 3, item_skus.count
      assert_equal item_skus.sort, ['ABC-123', 'GHOL-16-1001', 'GHOL-16-1001']
    end

    it "returns the list of items if it doesn't contain a black tie set" do
      items = [other, other]
      converted_items = BlackTieBundle.convert(items)

      items.each do |item|
        assert_includes converted_items, item
      end
    end

    def pencil
      InventoryUnitDouble.example(
        variant: VariantDouble.example(sku: "GEYE-01-WIP1-SET"),
        line_item: LineItemDouble.example(sku: "GHOL-16-1001")
      )
    end

    def nail_polish
      InventoryUnitDouble.example(
        variant: VariantDouble.example(sku: "GNP0-01-WIP1-SET"),
        line_item: LineItemDouble.example(sku: "GHOL-16-1001")
      )
    end

    def haloscope
      InventoryUnitDouble.example(
        variant: VariantDouble.example(sku: "GHS0-03-WIP1-SET"),
        line_item: LineItemDouble.example(sku: "GHOL-16-1001")
      )
    end

    def lip_gloss
      InventoryUnitDouble.example(
        variant: VariantDouble.example(sku: "GLIP-01-WIP1-SET"),
        line_item: LineItemDouble.example(sku: "GHOL-16-1001")
      )
    end

    def other
      InventoryUnitDouble.example
    end

  end
end
