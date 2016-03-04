require 'spec_helper'
require 'hushed/phase_1_set'

module Hushed
  describe "Hushed::Phase1Set" do

    it "checks if an item i a Phase 1" do
      assert Phase1Set.match(line_item("GPS1-5"))
      refute Phase1Set.match(line_item("non-phase-1"))
    end

    it "returns a collection of items included in the Phase 1 Set" do
      phase1Set = Hushed::Phase1Set.new(line_item("GPS1-5", 2))
      items = phase1Set.included_items

      assert_equal 4, items.count
      assert_includes_all items, [ milky_jelly, priming_moisturizer, balm_dotcom, skin_tint ]
    end

    it "returns the skin tint for Phase 1 Set -	Shade: Light" do
      phase1Set = Phase1Set.new(line_item("GPS1-5"))

      assert_equal "GPST100 - 2", phase1Set.skin_tint.sku
    end

    it "returns the skin tint for Phase 1 Set -	Shade: Medium" do
      phase1Set = Phase1Set.new(line_item("GPS2-5"))

      assert_equal "GPST200 - 2", phase1Set.skin_tint.sku
    end

    it "returns the skin tint for Phase 1 Set -	Shade: Dark" do
      phase1Set = Phase1Set.new(line_item("GPS3-5"))

      assert_equal "GPST300", phase1Set.skin_tint.sku
    end

    it "returns the skin tint for Phase 1 Set -	Shade: Deep" do
      phase1Set = Phase1Set.new(line_item("GPS4-5"))

      assert_equal "GPST400", phase1Set.skin_tint.sku
    end

    it "returns the skin tint for Phase 1 Set -	Shade: Rich" do
      phase1Set = Phase1Set.new(line_item("GPS5-5"))

      assert_equal "GPST500", phase1Set.skin_tint.sku
    end

    def assert_includes_all(collection, expected)
      collection.each { |item| assert_includes collection, item }
    end

    def line_item(sku = "GPS1-5", quantity = 1)
      LineItemDouble.example(sku: sku, quantity: quantity)
    end


    def milky_jelly
      LineItem.new("GMJC100", 97, 2, 18.0)
    end

    def priming_moisturizer
      LineItem.new("GPM100", 3, 2, 25.0)
    end

    def balm_dotcom
      LineItem.new("GPM100", 3, 2, 25.0)
    end

    def skin_tint
      LineItem.new("GPST100", 6, 2, 26.0)
    end

  end
end
