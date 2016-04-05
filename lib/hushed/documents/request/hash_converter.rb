module Hushed
  module Documents
    module Request
      module HashConverter
        def part_line_item_hash(part)
          {
            'ItemNumber'      => normalize_sku(part.variant.sku),
            'Line'            => part.variant.id,
            'QuantityOrdered' => part.line_item.quantity,
            'QuantityToShip'  => part.line_item.quantity,
            'UOM'             => 'EA',
            'Price'           => part.variant.price
          }
        end

        def line_item_hash(item)
          {
            'ItemNumber'      => normalize_sku(item.sku),
            'Line'            => item.id,
            'QuantityOrdered' => item.quantity,
            'QuantityToShip'  => item.quantity,
            'UOM'             => 'EA',
            'Price'           => item.price
          }
        end

        def ship_to_hash
          {
            'Company'    => ship_address.company,
            'Contact'    => full_name,
            'Address1'   => ship_address.address1,
            'Address2'   => ship_address.address2,
            'City'       => ship_address.city,
            'State'      => ship_address.state.name,
            'PostalCode' => ship_address.zipcode,
            'Country'    => ship_address.country.name
          }
        end

        def bill_to_hash
          {
            'Company'    => bill_address.company,
            'Contact'    => full_name,
            'Address1'   => bill_address.address1,
            'Address2'   => bill_address.address2,
            'City'       => bill_address.city,
            'State'      => bill_address.state.name,
            'PostalCode' => bill_address.zipcode,
            'Country'    => bill_address.country.name
          }
        end

        private
          def normalize_sku(sku)
            sku.chomp("-SET")
          end
      end
    end
  end
end
