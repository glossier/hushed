require 'spec_helper'
require 'hushed/documents/request/shipment_order'
require 'hushed/documents/request/hash_converter'

module Hushed
  module Documents
    module Request
      describe 'ShipmentOrder' do
        include Hushed::Documents::Request::HashConverter

        it 'serializes the line item into a hash' do
          inventory_unit = InventoryUnitDouble.example(
            variant: VariantDouble.example(sku: 'SKU42', prices: { 'USD' => MoneyDouble.example(cents: 995) })
          )

          hash = order_details(inventory_unit)

          assert_equal 'SKU42', hash['ItemNumber']
          assert_equal 'EA', hash['UOM']
          assert_equal 9.95, hash['Price']
        end

        it 'supports nil state' do
          address = AddressDouble.example(state: nil)

          hash = address_details(address)

          assert_nil hash['State']
        end
      end
    end
  end
end
