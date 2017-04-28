module Hushed
  class InventoryUnit
    attr_reader :variant

    def initialize(sku, price, gift_card)
      product = Product.new(gift_card)

      @variant = Variant.new(sku, price, product)
    end
  end

  class Variant
    attr_reader :sku, :price, :product

    def initialize(sku, price, product)
      @sku = sku
      @price = price
      @product = product
    end

    alias current_warehouse_sku sku
  end

  class Product
    attr_reader :gift_card

    def initialize(gift_card)
      @gift_card = gift_card
    end

    def gift_card?
      gift_card
    end
  end

  private_constant :Variant, :Product
end
