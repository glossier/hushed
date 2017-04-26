require 'time'
module Hushed
  module Documents
    module Response
      class ShipmentOrderResult
        attr_reader :io

        def initialize(options = {})
          @io = options[:io]
          @document = Nokogiri::XML::Document.parse(@io)
        end

        def client_id
          @client_id ||= so_result['ClientID']
        end

        def business_unit
          @business_unit ||= so_result['BusinessUnit']
        end

        def date_shipped
          @date_shipped ||= Time.parse(so_result['DateShipped']).utc
        end

        def order_number
          @order_number ||= so_result['OrderNumber']
        end

        def carton_count
          @carton_count ||= so_result['CartonCount'].to_i
        end

        def carrier
          @carrier ||= carton['Carrier']
        end

        def service_level
          @service_level ||= carton['ServiceLevel']
        end

        def tracking_number
          @tracking_number ||= carton['TrackingId']
        end

        def so_result
          @so_result ||= @document.css('SOResult').first
        end

        def carton
          @carton ||= @document.css('Carton').first
        end
      end
    end
  end
end
