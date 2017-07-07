require 'forwardable'
require 'hushed/documents/request/hash_converter'

module Hushed
  module Documents
    module Request
      class ShipmentOrderSummaryRequest
        include Hushed::Documents::Document
        extend Forwardable

        NAMESPACE = 'http://schemas.quietlogistics.com/V2/ShipmentOrderSummaryRequest.xsd'.freeze

        def_delegators :@client, :warehouse, :business_unit, :client_id

        def initialize(options = {})
          @client = options.fetch(:client)
        end

        def to_xml
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.ShipmentOrderSummaryRequest('xmlns' => NAMESPACE,
                                            'ClientId' => @client.client_id,
                                            'BusinessUnit' => @client.business_unit,
                                            'Warehouse' => 'ALL')
          end
          builder.to_xml
        end

        def type
          'ShipmentOrderSummaryRequest'
        end

        def date
          @date ||= Time.now
        end

        def filename
          @filename ||= "#{business_unit}_#{type}_#{date.strftime(DATEFORMAT)}.xml"
        end
      end
    end
  end
end
