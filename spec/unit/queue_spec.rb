require 'spec_helper'
require 'hushed/queue'
require 'hushed/error_message'

module Hushed
  describe 'Queue' do
    include Fixtures
    before do
      @sqs_queue = mock

      @client = mock
      @client.stubs(:to_quiet_queue).returns(@sqs_queue)
      @client.stubs(:from_quiet_queue).returns(@sqs_queue)
      @client.stubs(:quiet_inventory_queue).returns(@sqs_queue)

      @message = mock

      @queue = Queue.new(@client)
    end

    it 'should be able to write a message to a queue' do
      @message.stubs(:to_xml).returns('hello world')
      @sqs_queue.expects(:send_message).with('hello world')

      @queue.send(@message)
    end

    it 'should return a message when receiving from a queue' do
      @message.stubs(:body).returns(load_message('purchase_order_message'))
      @sqs_queue.expects(:receive_message).yields(@message)

      received_message = @queue.receive
      assert_equal 'PurchaseOrder', received_message.document_type
      assert_equal 'HUSHED_PurchaseOrder_1234_20100927_132505124.xml', received_message.document_name
    end

    it 'should return a message when receiving even if the queue did not return anything' do
      @sqs_queue.expects(:receive_message)

      received_message = @queue.receive
      assert_equal false, received_message.nil?
    end

    it 'should return an error message when receiving an error from a queue' do
      @message.stubs(:body).returns(load_message('error_message'))
      @sqs_queue.expects(:receive_message).yields(@message)

      received_message = @queue.receive
      assert_instance_of Hushed::ErrorMessage, received_message
    end

    it 'should be possible to get an approximate number of pending messages' do
      @sqs_queue.expects(:approximate_number_of_messages).returns(10)
      assert_equal 10, @queue.approximate_pending_messages
    end
  end
end
