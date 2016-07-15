require 'hushed/response'
require 'hushed/request'
require 'hushed/date_service'

module Hushed
  class Blackboard
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def post(document)
      bucket = client.to_quiet_bucket
      if bucket.objects[document.filename].write(document.to_xml)
        Message.new(:client => @client, :document => document)
      end
    end

    def fetch(message)
      bucket = client.from_quiet_bucket
      contents = bucket.objects[message.document_name].read
      build_document(message.document_type, contents)
    end

    def remove(message)
      bucket = client.from_quiet_bucket
      object = bucket.objects[message.document_name]
      if object.exists?
        object.delete
        true
      else
        false
      end
    end

    def build_document(type, contents)
      namespace = if Response.valid_type?(type)
        Documents::Response
      elsif Request.valid_type?(type)
        Documents::Request
      end
      namespace.const_get(type).new(:io => contents) if namespace
    end

    def retrieve_latest(document_name)
      blackboard = client.from_quiet_bucket
      documents = inventory_summary_documents(blackboard, document_name)
      get_latest_summary_report(documents)
    end

    private

    def inventory_summary_documents(blackboard, doc_name)
      doc_type = Regexp.new('\A' + doc_name + '(...)').freeze
      documents = blackboard.objects
      summary_documents = {}
      documents.each do |document|
        if document.key.match(doc_type).inspect.include?(doc_name)
          date_string = get_date_string(document.key)
          date = Hushed::DateService.new.build_date(date_string)
          summary_documents[date] = document
        end
        summary_documents
      end
      summary_documents
    end

    def get_latest_summary_report(documents)
      date_array = documents.keys
      most_recent_day = Hushed::DateService.new.most_recent_day(date_array)
      documents[most_recent_day]
    end

    def get_date_string(file_name)
      file_name.slice(26..31)
    end


  end
end
