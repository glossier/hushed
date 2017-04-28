module Hushed
  module Sku
    module_function

    def extract_and_normalize(variant)
      variant.sku.chomp('-SET')
    end
  end
end
