# frozen_string_literal: true

module Boards
  require 'csv'

  # Service that accepts +board+ returns CSV file with +board+ columns and cards
  class CsvExporter < ApplicationService
    # @return [Board] board for which CSV will be generated
    attr_reader :board

    # Sets initial values of new CsvExporter object
    # @param [Board] board board for which CSV will be generated
    # @return [CsvExporter] new instance of the service
    def initialize(board)
      @board = board
    end

    # Calls method +to_csv+ which generates CSV with +board+ columns and cards
    # @return [CSV] generated CSV file
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
