# frozen_string_literal: true

json.array! @boards do |board|
  json.partial! 'board', board: board

  json.creator do
    json.partial! 'api/v1/users/user', user: board.user
  end
end
