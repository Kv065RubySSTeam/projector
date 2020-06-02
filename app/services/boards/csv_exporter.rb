module Boards
  # CSV library
  require 'csv'

  class CsvExporter < ApplicationService
    attr_reader :board

    def initialize(board)
      @board = board
    end

    def call
      to_csv(board)
    end

    private

    def to_csv(board)
      attributes = %w[title description]
      CSV.generate(headers: false) do |csv|
        csv << attributes.map { |attr| board.send(attr) }
        columns = Column.joins(:board).where(board: board).includes(:user, :cards)

        columns.each do |column|
          column.cards.each do |card|
            body = card.body.to_plain_text
            csv << [card.title, body, card.user.full_name, column.name]
          end
        end
      end
    end
  end
end
