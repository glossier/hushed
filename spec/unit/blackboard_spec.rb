require 'spec_helper'
require 'hushed/blackboard'

module Hushed
  module Documents
    module Response
      class ThingerResponse
        attr_reader :contents
        def initialize(contents)
          @contents = contents
        end
      end
    end

    module Request
      class ThingerRequest
        attr_reader :contents
        def initialize(contents)
          @contents = contents
        end
      end
    end
  end
end

module Hushed
  describe "Blackboard" do
    before do
      @bucket = mock()

      @client = mock()
      @client.stubs(:to_quiet_bucket).returns(@bucket)
      @client.stubs(:from_quiet_bucket).returns(@bucket)

      @io = StringIO.new

      @document = mock()
      @document.stubs(:to_xml).returns("actually doesn't matter")
      @document.stubs(:filename).returns("abracadabra_1234_xyz.xml")

      @message = mock()
      @message.stubs(:document_type).returns('ShipmentOrderResult')
      @message.stubs(:document_name).returns('abracadabra_4321_zyx.xml')

      @blackboard = Blackboard.new(@client)
    end

    it "should be possible to post a document to the blackboard" do
      @bucket.expects(:objects).returns({@document.filename => @io})
      @blackboard.post(@document)
      assert_io(@document.to_xml, @io)
    end

    it "should be possible to build a document for a response type" do
      Response.expects(:valid_type?).returns(true)
      response = @blackboard.build_document('ThingerResponse', 'thinger')
      assert_equal 'thinger', response.contents[:io]
    end

    it "should be possible to build a document for a request type" do
      Request.expects(:valid_type?).returns(true)
      response = @blackboard.build_document('ThingerRequest', 'thinger')
      assert_equal 'thinger', response.contents[:io]
    end

    it "should return nil if the type was not valid" do
      assert_equal nil, @blackboard.build_document('ThingerRequest', 'thinger')
    end

    it "should be possible to fetch a document from the blackboard" do
      @io.write('fancy noodles')
      @io.rewind
      @bucket.expects(:objects).returns({@message.document_name => @io})
      Response.expects(:valid_type?).returns(true)
      @message.stubs(:document_type).returns('ThingerResponse')
      assert_equal 'fancy noodles', @blackboard.fetch(@message).contents[:io]
    end

    it "should be possible to remove a document from the blackboard" do
      s3object = mock()
      s3object.expects(:delete)
      s3object.expects(:exists?).returns(true)

      @bucket.expects(:objects).returns({@message.document_name => s3object})
      assert_equal true, @blackboard.remove(@message)
    end

    it "should not raise an exception if the document for removal couldn't be found" do
      s3object = mock()
      s3object.expects(:delete).never
      s3object.expects(:exists?).returns(false)

      @bucket.expects(:objects).returns({@message.document_name => s3object})
      assert_equal false, @blackboard.remove(@message)
    end

    def assert_io(expectation, io)
      io.rewind
      assert_equal expectation, io.read
    end
  end
end