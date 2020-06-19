json.title @card.title
json.body @card.body.body.to_plain_text if @card.body.body.present?
json.assignee @card.assignee.full_name if @card.assignee
json.user @card.user.full_name
json.tags @card.tag_list
