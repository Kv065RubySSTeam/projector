class ColumnTemplateBuilder < ApplicationService
  def initialize(board, user)
    @columns = board.columns
    @column = @columns.build(user_id: user.id)
  end

  def call
    @column.position = @columns.last_position.blank? ?
      1 : @columns.last_position + 1
    @column.name = 'Default Title'
    return nil unless @column.save

    @column
  end
end
