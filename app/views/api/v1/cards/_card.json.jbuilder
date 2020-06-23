json.(card, :id, :title, :position, :created_at, :updated_at)

json.body do
  json.partial! 'body', body: card.body
end
