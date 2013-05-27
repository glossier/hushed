require 'minitest/autorun'
require 'nokogiri'

module Fixtures
  def load_fixture(path)
    File.open(path, 'rb')
  end

  def load_response(response_name)
    load_fixture("spec/fixtures/documents/responses/#{response_name}.xml")
  end
end

class LineItemDouble
  DEFAULT_OPTIONS = {
    :id => 123456,
    :quantity => 1,
    :unit_of_measure => 'EA',
    :price => '12.95'
  }

  attr_reader :id, :quantity, :unit_of_measure, :price
  def initialize(options = {})
    @id = options[:id]
    @quantity = options[:quantity]
    @unit_of_measure = options[:unit_of_measure]
    @price = options[:price]
  end

  def self.example(options = {})
    self.new(DEFAULT_OPTIONS.merge(options))
  end
end

class AddressDouble
  DEFAULT_OPTIONS = {
    :company => 'Shopify',
    :name => 'John Smith',
    :address1 => '123 Fake St',
    :address2 => 'Unit 128',
    :city => 'Ottawa',
    :province_code => 'ON',
    :country_code => 'CA',
    :zip => 'K1N 5T5'
  }

  attr_reader :company, :name, :address1, :address2, :city, :province_code
  attr_reader :country_code, :zip
  def initialize(options = {})
    @company = options[:company]
    @name = options[:name]
    @address1 = options[:address1]
    @address2 = options[:address2]
    @city = options[:city]
    @province_code = options[:province_code]
    @country_code = options[:country_code]
    @zip = options[:zip]
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

class OrderDouble
  DEFAULT_OPTIONS = {
    :line_items => [LineItemDouble.example],
    :shipping_address => AddressDouble.example,
    :billing_address => AddressDouble.example,
    :note => 'Happy Birthday',
    :created_at => Time.new(2013, 04, 05, 12, 30, 00),
    :id => 123456,
    :shipping_lines => [ShippingLineDouble.new(code: "FEDEX_GROUND", price: "34.40", source: "fedex", title: "FedEx Ground")],
    :email => 'john@smith.com',
    :total_price => '123.45'
  }

  attr_reader :line_items, :shipping_address, :billing_address, :note, :email
  attr_reader :total_price, :email, :id, :type, :created_at, :shipping_lines
  def initialize(options = {})
    @line_items = options[:line_items]
    @shipping_address = options[:shipping_address]
    @billing_address = options[:billing_address]
    @note = options[:note]
    @created_at = options[:created_at]
    @id = options[:id]
    @shipping_lines = options[:shipping_lines]
    @email = options[:email]
    @total_price = options[:total_price]
  end

  def self.example(options = {})
    self.new(DEFAULT_OPTIONS.merge(options))
  end

  def type
    @type || "SO"
  end
end

class DocumentDouble
  attr_accessor :type, :name, :message_id, :warehouse, :date
end

class ClientDouble
  attr_accessor :client_id, :business_unit

  def initialize(options = {})
    @client_id = options[:client_id]
    @business_unit = options[:business_unit]
  end
end
