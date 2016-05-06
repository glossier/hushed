require 'hushed/line_item'

module Hushed
  class BalmDotcomTrio

    def initialize(item)
      @item = item
    end

    def self.match(item)
      item.sku == 'GBDT'
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
      LineItem.new("GBD300", @item.quantity, 10.0)
    end

    def cherry_balm
      LineItem.new("GBD400", @item.quantity, 10.0)
    end

    def rose_balm
      LineItem.new("GBD500", @item.quantity, 10.0)
    end
  end
end
