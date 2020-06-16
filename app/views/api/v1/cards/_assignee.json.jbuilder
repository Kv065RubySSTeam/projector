json.assignee do
  json.full_name @card.assignee.full_name
  json.email @card.assignee.email
end