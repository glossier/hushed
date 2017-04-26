require 'spec_helper'
require 'hushed'
require 'hushed/blackboard'

module Hushed
  describe 'BlackboardRemote' do
    include Configuration
    include Fixtures

    before do
      AWS.config(stub_requests: false)
      @client = Client.new(load_configuration)
      @blackboard = Blackboard.new(@client)
      @document = DocumentDouble.new(
        message_id: '1234567',
        date: Time.new(2013, 0o4, 0o5, 12, 30, 15).utc,
        filename: 'neat_beans.xml',
        client: @client,
        type: 'ShipmentOrderResult'
      )
    end

    after do
      buckets = [@client.to_quiet_bucket, @client.from_quiet_bucket]
      buckets.each { |bucket| bucket.objects.delete_all }
    end

    it 'should be able to write a document to an S3 bucket' do
      message = @blackboard.post(@document)
      file = message.document_name
      bucket = @client.to_quiet_bucket
      assert bucket.objects[file].exists?, "It appears that #{file} was not written to S3"
    end

    it 'should be able to fetch a document from an S3 bucket when given a message' do
      expected_contents = load_response('shipment_order_result')
      @client.from_quiet_bucket.objects[@document.filename].write(expected_contents)
      message = MessageDouble.new(document_name: @document.filename, document_type: @document.type)
      document = @blackboard.fetch(message)
      assert_equal expected_contents, document.io
    end
  end
end
