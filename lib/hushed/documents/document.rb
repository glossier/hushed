module Hushed
  module Documents
    class Document
      def to_xml
        raise NotImplementedError("To be implemented by subclasses")
      end

      def filename
      end
    end
  end
end