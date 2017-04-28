module Hushed
  class Queue
    attr_reader :client
    def initialize(client)
      @client = client
    end

    def send(message)
      queue = client.to_quiet_queue
      queue.send_message(message.to_xml)
    end

    def receive
      queue = client.from_quiet_queue
      message = nil
      queue.receive_message do |msg|
        message = build_message(msg)
      end
      message || Message.new
    end

    def approximate_pending_messages
      client.from_quiet_queue.approximate_number_of_messages
    end

    private

    def build_message(msg)
      if received_error? msg
        ErrorMessage.new(xml: msg.body)
      else
        Message.new(xml: msg.body)
      end
    end

    def received_error?(msg)
      msg.body.include? '<ErrorMessage'
    end
  end
end
