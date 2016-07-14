module Hushed
  class DateService

    def build_date(date_string)
      month = date_string.slice(0..1).to_i
      day = date_string.slice(2..3).to_i
      year = ("20" + date_string.slice(4..5)).to_i

      Date.new(year, month, day)
    end

    def most_recent_day(date_array)
      quick_sort(date_array).first
    end

    def quick_sort(date_array)
      if date_array.count == 1 || date_array.empty?
        date_array
      else
        pivot = date_array.sample
        delete_pivot(date_array, pivot)

        less = []
        greater = []

        split_array(date_array, pivot, less, greater)
        recursively_sort_dates(less, greater, pivot).flatten.compact
      end
    end

    private

    def split_array(date_array, pivot, less_array, greater_array)
      for date in date_array
        if date < pivot
          less_array << date
        elsif date > pivot
          greater_array << date
        end
      end
    end

    def recursively_sort_dates(less_array, greater_array, pivot)
      sorted_array = []
      sorted_array << self.most_recent_day(greater_array)
      sorted_array << pivot
      sorted_array << self.most_recent_day(less_array)
    end

    def delete_pivot(array, pivot)
      array.delete_at(array.index(pivot))
    end

  end
end
