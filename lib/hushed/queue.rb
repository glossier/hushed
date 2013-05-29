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
        message = Message.new(xml: msg.body)
      end
      message || Message.new
    end

    def approximate_pending_messages
      client.from_quiet_queue.approximate_number_of_messages
    end
  end
end