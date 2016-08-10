require 'hushed/inventory_unit'

module Hushed
  class BtrBundle

    def initialize(inventory_unit)
      @inventory_unit = inventory_unit
    end

    def self.match(inventory_unit)
      inventory_unit.variant.sku == 'GBTR'
    end

    def included_items
      [
        btr_bundle
      ]
    end

  private

    def btr_bundle
      InventoryUnit.new("GBTR", 10.0)
    end

  end
end
