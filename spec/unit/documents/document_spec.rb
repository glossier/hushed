module Hushed
  module Documents
    module DocumentInterfaceTestcases

      def test_it_should_be_able_to_generate_a_filename
        assert bn = @object.business_unit
        assert type = @object.type
        assert number = @object.document_number
        assert date = @object.date.strftime("%Y%m%d_%H%M%S")
        expected_filename = "#{bn}_#{type}_#{number}_#{date}.xml"
        assert_equal expected_filename, @object.filename
      end

      def test_it_should_respond_to_warehouse
        assert @object.respond_to?(:warehouse), "#{@object.class} does not respond to #warehouse"
      end

      def test_it_should_be_initializable_with_a_hash
        begin
          @object.class.new(:thinger => 123)
        rescue TypeError
          flunk "It should be possible to initialize #{@object.class} with an args hash"
        rescue StandardError
        end
      end

    end
  end

  describe "DocumentDouble" do
    include Documents::DocumentInterfaceTestcases

    before do
      @object = DocumentDouble.new(
        :message_id => '1234567',
        :date => Time.new(2013, 04, 05, 12, 30, 15).utc,
        :client => @client,
        :type => 'Thinger',
        :business_unit => 'HUSHED',
        :document_number => '123456'
      )
    end
  end
end
