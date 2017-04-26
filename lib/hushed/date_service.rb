module Hushed
  class DateService
    def self.build_date(date_string)
      Date.strptime(date_string, '%m%d%y')
    end

    def self.most_recent_day(date_array)
      date_array.max
    end
  end
end
