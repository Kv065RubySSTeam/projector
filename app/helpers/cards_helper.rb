module CardsHelper

  def sortable(column, title = nil)
    title ||= column.titleize
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {sort: column, direction: direction, load_new: true, page: 1 }, {remote: true}
  end

  def short_text(text)
    truncate(text, :length => 20)
  end
  
  def style_for_deleted(card)
    if card.discarded_at?
      "background-color: #a9a9a959"
    end
  end
end
