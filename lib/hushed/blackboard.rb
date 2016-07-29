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

    def retrieve_latest(document_name_prefix)
      documents = documents_with_prefix(document_name_prefix)
      get_latest_from(documents)
    end

    private

    def documents_with_prefix(doc_name_prefix)
      documents = client.from_quiet_bucket.objects
      documents_matching_prefix = {}
      documents.each do |document|
        if document.key.start_with?(doc_name_prefix)
          date_string = get_inventory_summary_date(document.key)
          date = Hushed::DateService.build_date(date_string)
          documents_matching_prefix[date] = document
        end
        documents_matching_prefix
      end
      documents_matching_prefix
    end

    def get_latest_from(documents)
      date_array = documents.keys
      most_recent_day = Hushed::DateService.most_recent_day(date_array)
      documents[most_recent_day]
    end

    def get_inventory_summary_date(file_name)
      file_name.slice(26..31)
    end


  end
end
