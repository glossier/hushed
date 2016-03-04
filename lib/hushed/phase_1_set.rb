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
      line_item(97 , "GMJC100", 18.0)
    end

    def priming_moisturizer
      line_item( 3, "GPM100", 25.0)
    end

    def balm_dotcom
      line_item(96, "GBD100-3", 12.0)
    end

    def skin_tint
      line_item(6, SKUS[@item.sku], 26.0)
    end

    def line_item(id, sku, price)
      LineItem.new(sku, id, @item.quantity, price)
    end

  end

  class LineItem < Struct.new(:sku, :id, :quantity, :price)
  end
end
