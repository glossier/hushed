require "forwardable"
require "hushed/documents/request/hash_converter"
require "hushed/black_tie_bundle"

module Hushed
  module Documents
    module Request
      class ShipmentOrderSummary
        include Hushed::Documents::Document

        NAMESPACE = "http://schemas.quietlogistics.com/V2/ShipmentOrderSummaryRequest.xsd"

        def initialize(options = {})
          @client   = options.fetch(:client)
        end

        def to_xml
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.ShipmentOrderSummaryRequest('xmlns' => NAMESPACE,
                                            'ClientId' => @client.client_id,
                                            'BusinessUnit' => @client.business_unit,
                                            'Warehouse' => @client.warehouse)
          end
          builder.to_xml
        end
      end
    end
  end
end
