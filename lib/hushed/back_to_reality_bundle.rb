require 'hushed/inventory_unit'

module Hushed
  module BackToRealityBundle
    extend self

    BUNDLE_SKU = "GBTR"
    NUMBER_OR_PARTS = 3;

    def contained_in?(inventory_units)
      inventory_units.any? { |unit| part_of_bundle(unit) }
    end

    def convert(inventory_units)
      quantity_of_bundles_to_add = number_of_bundles(inventory_units);

      converted_units = []
      inventory_units.map do |unit|
        converted_units << unit unless part_of_bundle(unit)
      end
      quantity_of_bundles_to_add.times do
        converted_units << back_to_reality_bundle
      end
      converted_units
    end

    private

    def number_of_bundles(inventory_units)
      inventory_units.find_all { |unit| part_of_bundle(unit) }.length / NUMBER_OR_PARTS
    end

    def part_of_bundle(inventory_unit)
      return false if is_a_bundle? inventory_unit
      inventory_unit.line_item.sku == BUNDLE_SKU
    end

    def back_to_reality_bundle
      InventoryUnit.new(BUNDLE_SKU, 40.0)
    end

    def replace_parts_with_bundle(inventory_units)
      converted_units = []



      units << back_to_reality_bundle
    end

    def is_a_bundle?(inventory_unit)
      inventory_unit.variant.sku == BUNDLE_SKU
    end
  end
end
