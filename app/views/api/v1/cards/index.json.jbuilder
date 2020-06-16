json.array!(@cards) do |card|
  json.title card.title
  json.body card.body.to_plain_text if card.body.present?
  json.(card, :created_at, :updated_at)
  json.author do
    json.partial! 'api/v1/cards/author', user: card.user
  end
  json.assignee card.assignee.full_name if card.assignee
  json.tags card.tag_list
end
