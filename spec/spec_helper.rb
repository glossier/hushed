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

class VariantDouble
  DEFAULT_OPTIONS = {
    id: 112233,
    sku: "ABC-123",
    price: '6.95'
  }

  attr_reader :id, :sku, :price
  def initialize(options = {})
    @id = options[:id]
    @sku = options[:sku]
    @price = options[:price]
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
  }

  attr_reader :id, :quantity, :price, :sku, :product
  def initialize(options = {})
    @id = options[:id]
    @quantity = options[:quantity]
    @price = options[:price]
    @sku = options[:sku]
    @product = options[:product]
  end

  def self.example(options = {})
    self.new(DEFAULT_OPTIONS.merge(options))
  end
end

class InventoryUnitDouble
  DEFAULT_OPTIONS = {
    id: 123456,
    variant: VariantDouble.example
  }

  attr_reader :id, :line_item, :variant
  def initialize(options = {})
    @id = options[:id]
    @variant = options[:variant]
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
    total_price: '123.45'
  }

  attr_reader :line_items, :ship_address, :bill_address, :note, :email
  attr_reader :total_price, :email, :id, :type, :created_at, :shipping_lines
  attr_reader :number

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
  end

  def self.example(options = {})
    self.new(DEFAULT_OPTIONS.merge(options))
  end

  def special_instructions
    @note
  end

  def shipping_address
    @ship_address
  end

  def billing_address
    @bill_address
  end

  def type
    @type || "SO"
  end
end

class ShipmentDouble
  DEFAULT_OPTIONS = {
    shipping_method: ShippingMethodDouble.example,
    number: "H#{rand.to_s[2..11]}",
    order: OrderDouble.example,
    inventory_units: [InventoryUnitDouble.example],
    address: AddressDouble.example,
    state: "pending",
    created_at: Time.new(2013, 04, 06, 13, 45, 00)
  }

  attr_reader :order, :number, :address, :shipping_method, :inventory_units, :created_at

  def initialize(options = {})
    @order = options[:order]
    @number = options[:number]
    @address = options[:address]
    @shipping_method = options[:shipping_method]
    @created_at = options[:created_at]
    @inventory_units = options[:inventory_units]
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
  attr_accessor :client_id, :business_unit

  def initialize(options = {})
    @client_id = options[:client_id]
    @business_unit = options[:business_unit]
  end
end
