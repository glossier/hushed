require 'spec_helper'
require 'hushed'
require 'hushed/blackboard'

module Hushed
  describe "BlackboardRemote" do
    include Configuration

    before do
      AWS.config(:stub_requests => false)
      @client = Client.new(load_configuration)
      @blackboard = Blackboard.new(@client)
      @document = @object = DocumentDouble.new(
        :message_id => '1234567',
        :date => Time.new(2013, 04, 05, 12, 30, 15).utc,
        :filename => 'neat_beans.xml',
        :client => @client,
        :type => 'Thinger'
      )
    end

    it "should be able to write a document to an S3 bucket" do
      message = @blackboard.post(@document)
      file = message.document_name
      bucket = @client.to_quiet_bucket
      assert bucket.objects[file].exists?, "It appears that #{file} was not written to S3"
    end

  end
end