module Hushed
  module Documents
    module Document
      DATEFORMAT = '%Y%m%d_%H%M%S'.freeze

      def to_xml
        raise NotImplementedError('To be implemented by subclasses')
      end

      def filename
        @filename ||= "#{business_unit}_#{type}_#{document_number}_#{date.strftime(DATEFORMAT)}.xml"
      end

      def message_id
        SecureRandom.uuid
      end
    end
  end
end
