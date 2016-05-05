require 'hushed/line_item'

module Hushed
  class Phase1Set

    SKUS = {
      "GPS1-5" => "GPST100 - 2",
      "GPS2-5" => "GPST200 - 2",
      "GPS3-5" => "GPST300",
      "GPS4-5" => "GPST400",
      "GPS5-5" => "GPST500"
    }

    def initialize(item)
      @item = item
    end

    def self.match(item)
      SKUS.key? item.sku
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
      line_item("GMJC100", 18.0)
    end

    def priming_moisturizer
      line_item("GPM100", 25.0)
    end

    def balm_dotcom
      line_item("GBD100-3", 12.0)
    end

    def skin_tint
      line_item(SKUS[@item.sku], 26.0)
    end

    def line_item(sku, price)
      LineItem.new(sku, @item.quantity, price)
    end

  end
end
