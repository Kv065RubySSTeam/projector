# frozen_string_literal: true

json.partial! 'column', column: @column

json.creator do
  json.partial! 'api/v1/users/user', user: @column.user
end
