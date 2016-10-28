require 'hushed/inventory_unit'

module Hushed
  module BlackTieBundle
    extend self

    BUNDLE_SKU = "GHOL-16-1001"
    NUMBER_OR_PARTS = 4;

    def convert(inventory_units)
      return inventory_units unless contained_in?(inventory_units)

      quantity_of_bundles_to_add = number_of_bundles(inventory_units);
      converted_units = inventory_units.reject { |unit| part_of_bundle(unit) }
      quantity_of_bundles_to_add.times do
        converted_units << black_tie_bundle
      end
      converted_units
    end

    private

    def number_of_bundles(inventory_units)
      inventory_units.find_all { |unit| part_of_bundle(unit) }.length / NUMBER_OR_PARTS
    end

    def part_of_bundle(inventory_unit)
      return false if is_a_bundle?(inventory_unit)
      inventory_unit.line_item.sku == BUNDLE_SKU
    end

    def black_tie_bundle
      InventoryUnit.new(BUNDLE_SKU, 50.0)
    end

    def contained_in?(inventory_units)
      inventory_units.any? { |unit| part_of_bundle(unit) }
    end

    def is_a_bundle?(inventory_unit)
      inventory_unit.variant.sku == BUNDLE_SKU
    end
  end
end
