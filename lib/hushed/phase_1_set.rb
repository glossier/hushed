require 'hushed/inventory_unit'

module Hushed
  class Phase1Set

    SKUS = {
      "GPS1-5" => "GPST100 - 2",
      "GPS2-5" => "GPST200 - 2",
      "GPS3-5" => "GPST300",
      "GPS4-5" => "GPST400",
      "GPS5-5" => "GPST500"
    }

    def initialize(inventory_unit)
      @inventory_unit = inventory_unit
    end

    def self.match(inventory_unit)
      SKUS.key? inventory_unit.variant.sku
    end

    def included_items
      [
        milky_jelly,
        priming_moisturizer,
        balm_dotcom,
        skin_tint
      ]
    end

    def milky_jelly
      inventory_unit("GMJC100", 18.0)
    end

    def priming_moisturizer
      inventory_unit("GPM100-2", 25.0)
    end

    def balm_dotcom
      inventory_unit("GBD100-3", 12.0)
    end

    def skin_tint
      inventory_unit(SKUS[@inventory_unit.variant.sku], 26.0)
    end

    def inventory_unit(sku, price)
      InventoryUnit.new(sku, price)
    end

  end
end
