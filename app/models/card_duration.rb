# frozen_string_literal: true

class CardDuration
  class Type < ActiveRecord::Type::Value
    def cast(value)
      if value.is_a?(String)
        return nil if string_invalid?(value)

        to_seconds(value)
      else
        super
      end
    end

    private

    def to_seconds(time)
      return 0 if time == '' || time == '0'

      time_sum = 0
      time.split(' ').each do |time_part|
        value = time_part.to_i
        type = time_part[-1, 1]
        case type
        when 'm'
          value
        when 'h'
          value *= 60
        when 'd'
          value *= 8 * 60
        else
          value
        end
        time_sum += value
      end
      validate_duration(time_sum)
    end

    def validate_duration(time)
      time <= 14_880 ? time : nil
    end

    def string_invalid?(value)
      return true if value.scan(/(\d+)d|\s+|(\d+)h|\s+|(\d+)m|(\d)+$/).empty? && !value.empty?
    end
  end
end
