require 'hushed/inventory_unit'

module Hushed
  class BalmDotcomTrio

    def initialize(inventory_unit)
      @inventory_unit = inventory_unit
    end

    def self.match(inventory_unit)
      inventory_unit.variant.sku == 'GBDT'
    end

    def included_items
      [
        mint_balm,
        cherry_balm,
        rose_balm
      ]
    end

  private

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
