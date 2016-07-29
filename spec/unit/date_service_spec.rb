require 'spec_helper'
require 'hushed/date_service'

module Hushed
  describe "DateService" do

    it "builds a date from an integer containing the month date and year" do
      date = DateService.build_date("062916")

      assert_equal 6, date.month
      assert_equal 29, date.day
      assert_equal 2016, date.year
    end

    it "determines the most recent date" do
      today = Date.today
      yesterday = today.prev_day
      before_yesterday = Date.new(1992, 12, 15)
      real_old = Date.new(1992, 02, 20)

      assert_equal today, DateService.most_recent_day([today])
      assert_equal yesterday, DateService.most_recent_day([yesterday, before_yesterday])
      assert_equal yesterday, DateService.most_recent_day([before_yesterday, yesterday])
      assert_equal today, DateService.most_recent_day([before_yesterday, today, yesterday])
      assert_equal today, DateService.most_recent_day([real_old, before_yesterday, yesterday, today])
      assert_equal today, DateService.most_recent_day([real_old, before_yesterday, today, yesterday])
    end
  end

end
