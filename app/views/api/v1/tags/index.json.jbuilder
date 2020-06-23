# frozen_string_literal: true

json.array!(@tags) do |tag|
  json.partial! 'tag', tag: tag
end
