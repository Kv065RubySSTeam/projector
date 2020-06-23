# frozen_string_literal: true

json.array! @board.users do |user|
  json.partial! 'api/v1/users/user', user: user

  json.admin user.is_admin?(@board)
end
