module Hushed
  class InventoryUnit
    attr_reader :variant

    def initialize(sku, price, gift_card)
      product = Product.new(gift_card)

      @variant = Variant.new(sku, price, product)
    end
  end

  private_constant :Variant, :Product

  Variant = Struct.new(:sku, :price, :product)

  class Product
    attr_reader :gift_card

    def initialize(gift_card)
      @gift_card = gift_card
    end

    def gift_card?
      gift_card
    end
  end
end
