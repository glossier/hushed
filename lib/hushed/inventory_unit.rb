Hushed::Variant = Struct.new(:sku, :price)

Hushed::InventoryUnit = Struct.new(:sku, :price) do
  def variant
    Hushed::Variant.new(sku, price)
  end
end
