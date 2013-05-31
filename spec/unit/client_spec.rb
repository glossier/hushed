require 'spec_helper'
require 'hushed/client'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/hash/keys'

module Hushed
  describe "Client" do
    before do
      AWS.config(:stub_requests => true)
      @options = {
        access_key_id: 'abracadabra',
        secret_access_key: 'alakazam',
        client_id: 'HUSHED',
        business_unit: 'HUSHED',
        buckets: {
          to: 'hushed-to-quiet',
          from: 'hushed-from-quiet'
        },
        queues: {
          to: 'http://queue.amazonaws.com/123456789/hushed_to_quiet',
          from: 'http://queue.amazonaws.com/123456789/hushed_from_quiet',
          inventory: 'http://queue.amazonaws.com/123456789/hushed_inventory'
        }
      }
      @client = Client.new(@options)
    end

    after do
      AWS.config(:stub_requests => false)
    end

    it "should be able to handle configuration that is passed in with keys as strings" do
      client = Client.new(@options.stringify_keys)
      assert_equal 'HUSHED', client.client_id
      assert_equal 'HUSHED', client.business_unit
    end

    it "should not be possible to initialize a client without credentials" do
      assert_raises Client::InitializationError do
        Client.new(@options.except(:access_key_id, :secret_access_key))
      end
    end

    it "should not be possible to initialize a client without a client_id" do
      assert_raises Client::InitializationError do
        Client.new(@options.except(:client_id))
      end
    end

    it "should not be possible to initialize a client with a business_unit" do
      assert_raises Client::InitializationError do
        Client.new(@options.except(:business_unit))
      end
    end

    it "should not be possible to initialize a client with missing bucket information" do
      assert_raises Client::InitializationError do
        Client.new(@options.except(:buckets))
      end
    end

    it "should not be possible to initialize a client with partial bucket information" do
      assert_raises Client::InitializationError do
        buckets = {to: 'neato'}
        Client.new(@options.merge(buckets: buckets))
      end
    end

    it "should not be possible to initialize a client with missing queue information" do
      assert_raises Client::InitializationError do
        Client.new(@options.except(:queues))
      end
    end

    it "should not be possible to initialize a client with partial queue information" do
      assert_raises Client::InitializationError do
        queues = {inventory: 'neato'}
        Client.new(@options.merge(queues: queues))
      end
    end

    it "should raise an error if the bucket names are invalid" do
      AWS::S3::Bucket.any_instance.expects(:exists?).returns(false)
      assert_raises Client::InvalidBucketError do
        @client.to_quiet_bucket
      end
    end

    it "should raise an error if the queue names are invalid" do
      AWS::SQS::Queue.any_instance.expects(:exists?).returns(false)
      assert_raises Client::InvalidQueueError do
        @client.to_quiet_queue
      end
    end
  end
end