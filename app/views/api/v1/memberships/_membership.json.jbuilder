json.(membership, :admin, :created_at, :updated_at)

json.board do
  json.partial! 'api/v1/boards/board', board: membership.board
end

json.member do
  json.partial! 'api/v1/users/user', user: membership.user
end
