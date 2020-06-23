# frozen_string_literal: true

json.array! @cards do |card|
  json.partial! 'card', card: card

  json.creator do
    json.partial! 'api/v1/users/user', user: card.user
  end

  if card.assignee.present?
    json.assignee do
      json.partial! 'api/v1/users/user', user: card.assignee
    end
  end
end
