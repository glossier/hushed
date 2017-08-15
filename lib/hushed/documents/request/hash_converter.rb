require 'hushed/sku'

module Hushed
  module Documents
    module Request
      module HashConverter
        def order_details(item)
          details = {
            'ItemNumber'      => item.variant.current_warehouse_sku,
            'UOM'             => 'EA',
            'Price'           => item.variant.localized_price(item.order.currency).to_d
          }
          details['ItemIDCapture'] = true if item.variant.product.gift_card?
          details
        end

        def ship_to_hash
          address_details(ship_address)
        end

        def bill_to_hash
          address_details(bill_address)
        end

        def address_details(address)
          details = {
            'Company'    => address.company,
            'Contact'    => address.full_name,
            'Address1'   => address.address1,
            'Address2'   => address.address2,
            'City'       => address.city,
            'PostalCode' => address.zipcode,
            'Country'    => address.country.name
          }
          details['State'] = address.state.name if address.state
          details['Phone'] = address.phone if address.phone
          details
        end
      end
    end
  end
end
