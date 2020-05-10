module Cards
  class UpdateService < ApplicationService
    def initialize(card, column, target_cards_id_str, source_cards_id_str)
      @card, @column = card, column
      @target_cards_id_str = target_cards_id_str
      @source_cards_id_str = source_cards_id_str
    end

    def call
      @card.update(column_id: @column.id, position: 0)
      update_cards_position(@target_cards_id_str)
      if @source_cards_id_str
        update_cards_position(@source_cards_id_str)
      end
    end

    private
    def update_cards_position(cards_postions_id_str)
      cards_positions_id = eval(cards_postions_id_str)
      cards_positions_id.each_with_index do |card_id, index|
        card = Card.find(card_id)
        card.position = index + 1
        card.save(validate: false)
      end
    end
  end
end
