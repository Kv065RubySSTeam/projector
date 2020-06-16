json.title @card.title
json.body @card.body.body.to_plain_text
json.assignee @card.assignee.full_name if @card.assignee
json.user @card.user.full_name
json.tags @card.tag_list
json.comments @card.comments do |comment|
  json.author comment.user, :email, :full_name 
  json.body comment.body
end