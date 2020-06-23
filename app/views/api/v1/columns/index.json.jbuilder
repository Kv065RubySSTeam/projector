# frozen_string_literal: true

json.array! @columns do |column|
  json.partial! 'column', column: column

  json.creator do
    json.partial! 'api/v1/users/user', user: column.user
  end
end
