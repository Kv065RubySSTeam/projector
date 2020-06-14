class CardDuration
  class Type < ActiveRecord::Type::Value
    def cast(value)
      if value.is_a?(String)
        to_seconds(value)
      else
        super
      end
    end

    private

    def to_seconds(time)
      time_sum = 0
      time.split(' ').each do |time_part|
        value = time_part.to_i
        type = time_part[-1,1]
        case type
        when 'm'
          value *= 60
        when 'h'
          value *= 60*60
        when 'd'
          value *= 8*60*60
        else
          value *= 60
        end
        time_sum += value
      end
      time_sum
    end
  end
  
end
