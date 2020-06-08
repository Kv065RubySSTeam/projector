json.(column, :name, :position,
  :created_at, :updated_at)

json.creator do
  json.partial! 'api/v1/users/user', user: column.user
end
