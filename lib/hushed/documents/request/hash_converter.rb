module Hushed
  module Documents
    module Request
      module HashConverter
        def order_details(item)
          details = {
            'ItemNumber'      => item.variant.current_warehouse_sku,
            'UOM'             => 'EA',
            'Price'           => item.variant.price
          }
          details['ItemIDCapture'] = true if item.variant.product.gift_card?
          details
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
      end
    end
  end
end
