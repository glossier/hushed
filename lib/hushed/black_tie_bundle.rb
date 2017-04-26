require 'hushed/inventory_unit'

module Hushed
  module BlackTieBundle
    module_function

    BUNDLE_SKU = 'GHOL-16-1001'.freeze
    PARTS = ['GLIP-01-WIP1', 'GHS0-03-WIP1', 'GNP0-01-WIP1', 'GEYE-01-WIP1'].freeze
    NUMBER_OF_PARTS = 4

    def convert(inventory_units)
      return inventory_units unless contains_bundle?(inventory_units)

      quantity_of_bundles_to_add = number_of_bundles(inventory_units)
      converted_units = inventory_units.reject { |unit| part_of_bundle(unit) }
      quantity_of_bundles_to_add.times do
        converted_units << black_tie_bundle
      end
      converted_units
    end

    private

    def number_of_bundles(inventory_units)
      inventory_units.find_all { |unit| part_of_bundle(unit) }.length / NUMBER_OF_PARTS
    end

    def part_of_bundle(inventory_unit)
      return false if bundle?(inventory_unit)
      ['GHOL-16-1001', 'phase1bts'].include?(inventory_unit.line_item.sku) &&
        PARTS.include?(Hushed::Sku.extract_and_normalize(inventory_unit.variant))
    end

    def black_tie_bundle
      InventoryUnit.new(BUNDLE_SKU, 50.0, false)
    end

    def contains_bundle?(inventory_units)
      inventory_units.any? { |unit| part_of_bundle(unit) }
    end

    def bundle?(inventory_unit)
      inventory_unit.variant.sku == BUNDLE_SKU
    end
  end
end
