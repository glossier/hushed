module Hushed
  class Variant < Struct.new(:sku, :price, :product); end

  class Product < Struct.new(:gift_card)
    def gift_card?
      gift_card
    end
  end

  class InventoryUnit < Struct.new(:sku, :price, :gift_card)
    def variant
      Variant.new(sku, price, Product.new(gift_card))
    end
  end
end
