json.title @card.title
json.body @card.body.body.to_plain_text
json.assignee @card.assignee.full_name if @card.assignee
json.tags @card.tag_list
