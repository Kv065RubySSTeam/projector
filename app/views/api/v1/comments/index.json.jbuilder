# frozen_string_literal: true

json.array! @comments do |comment|
  json.partial! 'comment', comment: comment

  json.creator do
    json.partial! 'api/v1/users/user', user: comment.user
  end
end
