module Cards
  class UpdatePositionService < ApplicationService
    attr_accessor :card,
                  :column,
                  :target_card_ids,
                  :source_card_ids

    def initialize(card, column, target_cards_ids, source_cards_ids = nil)
      @card, @column = card, column
      @target_cards_ids = eval(target_cards_ids)
      @source_cards_ids = eval(source_cards_ids) if source_cards_ids.is_a? String
    end

    def call
      @card.update(column_id: @column.id, position: 0)
      update_cards_position(@target_cards_ids)
      if @source_cards_ids
        update_cards_position(@source_cards_ids)
      end
    end

    private
    def update_cards_position(card_ids)
      cards_to_update = Card.where(id: card_ids)
      cards_to_update.each_with_index do |card_to_update, index|
        card_to_update.position = index + 1
        card_to_update.save(validate: false)
      end
    end
  end
end
