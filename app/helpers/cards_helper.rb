module CardsHelper

  def sortable(column, title = nil)
    title ||= column.titleize
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {sort: column, direction: direction, load_new: true, page: 1, filter: sort_filter}, {remote: true}
  end

  def short_text(text)
    truncate(text, :length => 17)
  end

  def style_for_deleted(card)
    card.discarded_at? ? "background-color: #a9a9a959" : "cursor: pointer"
  end

  def card_comment(card)
    unless card.comments.blank?
    "<div class=\"kanban-comment d-flex align-items-center mr-50\">
      <i class=\"bx bx-message font-size-small mr-25\"></i>
      <span class=\"font-size-small\">#{card.comments.count}</span>
    </div>".html_safe
    end
  end

  def card_date(time)
    full_time = [time.strftime('%B'), time.day].join(" ")
    "<div class=\"kanban-due-date d-flex align-items-center mr-50\">
      <i class=\"bx bx-time-five font-size-small mr-25\"></i>
      <span class=\"font-size-small\">#{full_time}</span>
    </div>".html_safe
  end

end
