module Hushed
  module Sku
    extend self

    def extract_and_normalize(variant)
      variant.sku.chomp("-SET")
    end
  end
end
