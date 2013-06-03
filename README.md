# Hushed

Client library for integrating with the Quiet Logistics API

## Installation

Add this line to your application's Gemfile:

    gem 'hushed'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hushed

## Usage

Basic usage for Hushed goes as follows:


```ruby
require 'hushed'
require 'hushed/documents/request/shipment_order'

credentials = {
  access_key_id: 'AWS_ACCESS_KEY', secret_access_key: 'SECRET_ACCESS_KEY',
  client_id: 'QUIET CLIENT ID', business_unit: 'QUIET BUSINESS UNIT',
  warehouse: 'QUIET WAREHOUSE',
  buckets: {
    to: 'hushed-to-quiet',
    from: 'hushed-from-quiet'
  },
  queues: {
    to: http://queue.amazonaws/1234567890/hushed_to_quiet
    from: http://queue.amazonaws/1234567890/hushed_from_quiet
    inventory: http://queue.amazonaws/1234567890/hushed_inventory
  }
}
client = Hushed::Client.new(credentials)
order = Order.new # Orders are expected to have similar attributes as ShopifyAPI::Order
document = Hushed::Documents::Request::ShipmentOrder.new(client: client, order: order)

blackboard = Hushed::Blackboard.new(client)
queue = Hushed::Queue.new(client)

message = blackboard.post(document)
queue.send(message)

response_message = queue.receive
response_document = blackboard.fetch(message)
process_document(response_document)
blackboard.remove(message)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
