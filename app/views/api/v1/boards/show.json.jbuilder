# frozen_string_literal: true

json.partial! 'board', board: @board

json.creator do
  json.partial! 'api/v1/users/user', user: @board.user
end
