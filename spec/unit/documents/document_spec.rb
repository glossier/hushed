module Hushed
  module Documents
    module DocumentInterfaceTestcases
      def test_it_should_be_able_to_generate_a_filename
        assert bn = @object.business_unit
        assert type = @object.type
        assert number = @object.document_number
        assert date = @object.date.strftime('%Y%m%d_%H%M%S')
        expected_filename = "#{bn}_#{type}_#{number}_#{date}.xml"
        assert_equal expected_filename, @object.filename
      end

      def test_it_should_respond_to_warehouse
        assert @object.respond_to?(:warehouse), "#{@object.class} does not respond to #warehouse"
      end

      def test_it_should_be_initializable_with_a_hash
        @object.class.new(type: 'Thinger')
      rescue TypeError
        flunk "It should be possible to initialize #{@object.class} with an args hash"
      end
    end
  end

  describe 'DocumentDouble' do
    include Documents::DocumentInterfaceTestcases

    before do
      @object = DocumentDouble.new(
        message_id: '1234567',
        date: Time.new(2013, 0o4, 0o5, 12, 30, 15).utc,
        client: @client,
        type: 'Thinger',
        business_unit: 'HUSHED',
        document_number: '123456'
      )
    end
  end
end
