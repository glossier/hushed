require 'aws/s3'
require 'aws/sqs'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/hash/indifferent_access'

module Hushed
  class Client

    class InitializationError < StandardError; end
    class InvalidBucketError < StandardError; end
    class InvalidQueueError < StandardError; end

    attr_reader :client_id, :business_unit, :warehouse

    def initialize(options = {})
      options        = options.with_indifferent_access
      @buckets       = options[:buckets]
      @queues        = options[:queues]
      @client_id     = options[:client_id]
      @warehouse     = options[:warehouse]
      @business_unit = options[:business_unit]
      @credentials   = options.slice(:access_key_id, :secret_access_key)
      verify!
    end

    def to_quiet_bucket
      @to_quiet_bucket ||= fetch_bucket(@buckets[:to])
    end

    def from_quiet_bucket
      @from_quiet_bucket ||= fetch_bucket(@buckets[:from])
    end

    def to_quiet_queue
      @to_quiet_queue ||= fetch_queue(@queues[:to])
    end

    def from_quiet_queue
      @from_quiet_queue ||= fetch_queue(@queues[:from])
    end

    def quiet_inventory_queue
      @quiet_inventory_queue ||= fetch_queue(@queues[:inventory])
    end

    private
    def sqs_client
      @sqs_client ||= AWS::SQS.new(@credentials)
    end

    def s3_client
      @s3_client ||= AWS::S3.new(@credentials)
    end

    def fetch_bucket(name)
      bucket = s3_client.buckets[name]
      raise(InvalidBucketError.new("#{name} is not a valid bucket")) unless bucket.exists?
      bucket
    end

    def fetch_queue(url)
      queue = sqs_client.queues[url]
      raise(InvalidQueueError.new("#{url} is not a valid queue")) unless queue.exists?
      queue
    end

    def verify!
      raise(InitializationError.new("Credentials cannot be missing")) unless all_credentials?
      raise(InitializationError.new("Both to and from buckets need to be set")) unless all_buckets?
      raise(InitializationError.new("To, From and Inventory queues need to be set")) unless all_queues?
      raise(InitializationError.new("client_id needs to be set")) unless @client_id
      raise(InitializationError.new("business_unit needs to be set")) unless @business_unit
      raise(InitializationError.new("warehouse needs to be set")) unless @warehouse
    end

    def all_credentials?
      has_keys?(@credentials, [:access_key_id, :secret_access_key])
    end

    def all_buckets?
      has_keys?(@buckets, [:from, :to])
    end

    def all_queues?
      has_keys?(@queues, [:from, :to, :inventory])
    end

    def has_keys?(hash, keys)
      keys.reduce(hash) {|result, key| result && hash[key]}
    end
  end
end
