require 'spec_helper'
require 'hushed/error_message'

module Hushed
  describe ErrorMessage do
    include Fixtures

    before do
      @xml_content = load_message('error_message')
      @message = ErrorMessage.new(xml: @xml_content)
    end

    it "should be able to generate an XML document" do
      assert_equal normalize(@xml_content), normalize(@message.to_xml)
    end

    it "extracts the shipment number from the error message" do
      assert_equal "H123456789", @message.shipment_number
    end

    it "returns nil for shipment number if it cannot find it" do
      message = ErrorMessage.new(xml: "<ErrorMessage ResultDescription='No shipping number'/>")

      assert_nil message.shipment_number
    end

    def normalize(content)
      content.delete("\n").squeeze(" ")
    end
  end
end
