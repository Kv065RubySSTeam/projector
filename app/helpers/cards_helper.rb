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

  def card_date(card)
    full_date = nil
    if card.start_date.present?
      full_date = [card.start_date.strftime('%B'), card.start_date.day].join(" ") 

      if  Date.today == card.start_date
        full_date = "Today"
      elsif Date.tomorrow == card.start_date
        full_date = "Tomorrow"
      elsif Date.yesterday == card.start_date
        full_date = "Yesterday"
      end
    end
    
    "<div class=\"kanban-due-date d-flex mr-50\">
      <i class=\"bx bx-calendar-event mr-25\"></i>
      <span class=\"font-size-small\">#{full_date}</span>
    </div>
    <div class=\"kanban-due-date d-flex mr-50\">
      <i class=\"bx bxs-time-five mr-25\"></i>
      <span class=\"font-size-small\">#{card_duration(card)}</span>
    </div>".html_safe
  end

  def event_color(card)
    today_date = Date.today
    color = "info"
    if card.start_date.nil?
      color = "info"
    elsif today_date == card.start_date
      color = "success"
    elsif Date.tomorrow == card.start_date
      color = "warning"
    elsif today_date > card.start_date
      color = "danger"
    end
    return color 
  end

  def card_duration(card)
    return if card.duration == 0
    "%2dd %2dh %2dm" % [card.duration / (8 * 60 * 60), (card.duration / 3600) % 8, card.duration / 60 % 60]
  end
end
