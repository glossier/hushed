require 'spec_helper'
require 'hushed/blackboard'
require 'hushed/documents/response/inventory_summary_document'

module Hushed
  describe "Retrieves the latest document from Blackboard" do
    include Fixtures

    it "given a regex matcher" do
      client = mock()
      bucket = mock()

      client.stubs(:from_quiet_bucket).returns(bucket)
      bucket.stubs(:objects).returns([inventory_summary])

      assert_equal inventory_summary.key, blackboard(client).retrieve_latest("InventorySummary-GLOSSIER-").key
      assert_equal inventory_summary.read, blackboard(client).retrieve_latest("InventorySummary-GLOSSIER-").read
    end

    def inventory_summary
      S3ObjectDouble.new("InventorySummary-GLOSSIER-063016-024504.xml", load_response('inventory_summary'))
    end

    def blackboard(client)
      blackboard = Hushed::Blackboard.new(client)
    end

  end

  class S3ObjectDouble
    def initialize(name, content)
      @content = content
      @name = name
    end

    def key
      @name
    end

    def read
      @content
    end
  end

end
