require 'minitest/autorun'
require 'nokogiri'
require 'yaml'
require 'mocha/setup'
require 'hushed'
require 'pry'

module Fixtures
  def load_fixture(path)
    File.open(path, 'rb').read
  end

  def load_response(response_name)
    load_fixture("spec/fixtures/documents/responses/#{response_name}.xml")
  end

  def load_message(message_name)
    load_fixture("spec/fixtures/messages/#{message_name}.xml")
  end
end

module Configuration
  def load_configuration
    test_credentials_file = ENV['HOME'] + '/.hushed/credentials.yml'
    test_credentials_file = "spec/fixtures/credentials.yml" unless File.exists?(test_credentials_file)
    YAML.load(File.open(test_credentials_file, 'rb'))
  end
end

class VirtualGiftCardDouble
  DEFAULT_OPTIONS = {
    recipient_name: 'John',
    purchaser_name: 'Jane'
  }

  attr_reader :recipient_name, :purchaser_name
  def initialize(options = {})
    @recipient_name = options[:recipient_name]
    @purchaser_name = options[:purchaser_name]
  end

  def self.example(options = {})
    self.new(DEFAULT_OPTIONS.merge(options))
  end
end

class ProductDouble
  DEFAULT_OPTIONS = {
    gift_card: false
  }

  attr_reader :gift_card
  def initialize(options = {})
    @gift_card = options[:gift_card]
  end

  def gift_card?
    gift_card
  end

  def self.example(options = {})
    self.new(DEFAULT_OPTIONS.merge(options))
  end
end

class LineItemDouble
  DEFAULT_OPTIONS = {
    id: 123456,
    quantity: 1,
    price: '12.95',
    sku: "ABC-123",
    gift_cards: []
  }

  attr_reader :id, :quantity, :price, :sku, :product, :gift_cards
  def initialize(options = {})
    @id = options[:id]
    @quantity = options[:quantity]
    @price = options[:price]
    @sku = options[:sku]
    @gift_cards = options[:gift_cards]
  end

  def self.example(options = {})
    self.new(DEFAULT_OPTIONS.merge(options))
  end
end

class VariantDouble
  DEFAULT_OPTIONS = {
    id: 112233,
    sku: "ABC-123",
    price: '6.95',
    product: ProductDouble.example
  }

  attr_reader :id, :sku, :price, :product
  def initialize(options = {})
    @id = options[:id]
    @sku = options[:sku]
    @price = options[:price]
    @product = options[:product]
  end

  def self.example(options = {})
    self.new(DEFAULT_OPTIONS.merge(options))
  end
end

class InventoryUnitDouble
  DEFAULT_OPTIONS = {
    id: 123456,
    variant: VariantDouble.example,
    line_item: LineItemDouble.example
  }

  attr_reader :id, :line_item, :variant
  def initialize(options = {})
    @id = options[:id]
    @variant = options[:variant]
    @line_item = options[:line_item]
  end

  def self.example(options = {})
    self.new(DEFAULT_OPTIONS.merge(options))
  end
end

class StateDouble
  DEFAULT_OPTIONS = {
    iso_name: "CANADA",
    name: "Ontario",
    abbr: "ON",
  }

  attr_reader :name

  def initialize(options = {})
    @name = options[:name]
  end

  def self.example(options = {})
    self.new(DEFAULT_OPTIONS.merge(options))
  end
end

class CountryDouble
  DEFAULT_OPTIONS = {
    iso_name: "CANADA",
    name: "Canada",
    iso: "CA"
  }

  attr_reader :name

  def initialize(options = {})
    @name = options[:name]
  end

  def self.example(options = {})
    self.new(DEFAULT_OPTIONS.merge(options))
  end

end

class AddressDouble
  DEFAULT_OPTIONS = {
    company: 'Shopify',
    name: 'John Smith',
    address1: '123 Fake St',
    address2: 'Unit 128',
    city: 'Ottawa',
    country: CountryDouble.example,
    state: StateDouble.example,
    zipcode: 'K1N 5T5'
  }

  attr_reader :company, :name, :address1, :address2, :city, :country, :state, :zipcode

  def initialize(options = {})
    @company = options[:company]
    @name = options[:name]
    @address1 = options[:address1]
    @address2 = options[:address2]
    @city = options[:city]
    @country = options[:country]
    @state = options[:state]
    @zipcode = options[:zipcode]
  end

  def full_name
    name
  end

  def self.example(options = {})
    self.new(DEFAULT_OPTIONS.merge(options))
  end
end

class ShippingLineDouble
  def initialize(options = {})
    @options = options
  end

  def carrier
    @options[:code].split('_').first
  end

  def service_level
    @options[:code].split('_').last
  end
end

class ShippingMethodDouble
  DEFAULT_OPTIONS = {
    name: "UPS Ground",
    admin_name: "fed001",
    code: "fedex",
    carrier: "FEDEX",
    service_level: "GROUND"
  }

  attr_reader :name, :admin_name, :code, :carrier, :service_level

  def initialize(options = {})
    @name = options[:name]
    @admin_name = options[:admin_name]
    @code = options[:code]
    @carrier = options[:carrier]
    @service_level = options[:service_level]
  end

  def self.example(options = {})
    self.new(DEFAULT_OPTIONS.merge(options))
  end
end

class GiftDouble
  DEFAULT_OPTIONS = {
    id: 1,
    active: true,
    from: "from",
    to: "to",
    message: "HBD"
  }

  attr_reader :from, :to, :message

  def initialize(options = {})
    @from = options[:from]
    @to = options[:to]
    @message = options[:message]
    @active = options[:active]
  end

  def self.example(options = {})
    self.new(DEFAULT_OPTIONS.merge(options))
  end

  def active?; !!@active; end
end

class OrderDouble
  DEFAULT_OPTIONS = {
    number: "GLO#{rand.to_s[2..11]}",
    line_items: [LineItemDouble.example],
    ship_address: AddressDouble.example,
    bill_address: AddressDouble.example,
    note: 'Happy Birthday',
    created_at: Time.new(2013, 04, 05, 12, 30, 00),
    id: 123456,
    email: 'john@smith.com',
    total_price: '123.45',
    gift: GiftDouble.example
  }

  attr_reader :line_items, :ship_address, :bill_address, :note, :email,
   :total_price, :email, :id, :created_at, :shipping_lines, :number, :gift
  alias_method :shipping_address, :ship_address
  alias_method :billing_address, :bill_address

  def initialize(options = {})
    @line_items = options[:line_items]
    @ship_address = options[:ship_address]
    @bill_address = options[:bill_address]
    @note = options[:note]
    @created_at = options[:created_at]
    @id = options[:id]
    @shipping_lines = options[:shipping_lines]
    @email = options[:email]
    @total_price = options[:total_price]
    @number = options[:number]
    @gift = options[:gift]
  end

  def self.example(options = {})
    self.new(DEFAULT_OPTIONS.merge(options))
  end

  def type
    @type || 'SO'
  end

  def gift_cards
    line_items.map(&:gift_cards).flatten
  end
end

class ShipmentDouble
  DEFAULT_OPTIONS = {
    shipping_method: ShippingMethodDouble.example,
    number: "H#{rand.to_s[2..11]}",
    order: OrderDouble.example,
    inventory_units_to_fulfill: [InventoryUnitDouble.example],
    state: "pending",
    created_at: Time.new(2013, 04, 06, 13, 45, 00),
    value_added_services: [],
    carrier: "FEDEX",
    service_level: "GROUND"
  }

  attr_reader :order, :number, :shipping_method, :inventory_units_to_fulfill, :created_at, :value_added_services, :carrier, :service_level

  def initialize(options = {})
    @order = options[:order]
    @number = options[:number]
    @shipping_method = options[:shipping_method]
    @created_at = options[:created_at]
    @inventory_units_to_fulfill = options[:inventory_units_to_fulfill]
    @value_added_services = options[:value_added_services] if options[:value_added_services]
    @carrier = options[:carrier]
    @service_level = options[:service_level]
  end

  def self.example(options = {})
    self.new(DEFAULT_OPTIONS.merge(options))
  end
end

class DocumentDouble
  include Hushed::Documents::Document
  attr_accessor :type, :message_id, :warehouse, :date, :client
  attr_accessor :business_unit, :document_number, :io

  def initialize(options = {})
    options.each do |key, value|
      self.public_send("#{key}=".to_sym, value)
    end
  end

  def to_xml
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.DocumentDouble 'Hello World'
    end
    builder.to_xml
  end

  def filename=(filename)
    @filename = filename
  end
end

class MessageDouble
  attr_accessor :document_name, :document_type

  def initialize(options = {})
    @document_name = options[:document_name]
    @document_type = options[:document_type]
  end
end

class ClientDouble
  attr_accessor :client_id, :business_unit, :warehouse

  def initialize(options = {})
    @client_id = options[:client_id]
    @business_unit = options[:business_unit]
    @warehouse = options[:warehouse]
  end
end
