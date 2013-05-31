module Hushed
  module Documents
    module DocumentInterfaceTestcases

      def test_it_should_be_able_to_generate_a_filename
        bn = @client.business_unit
        type = @object.type
        number = @object.document_number
        date = @object.date.strftime("%Y%m%d_%H%M%S")
        expected_filename = "#{bn}_#{type}_#{number}_#{date}.xml"
        assert_equal expected_filename, @object.filename
      end
    end
  end
end
