json.array!(@tags) do |tag|
  json.name tag.name
  json.id tag.id
end
