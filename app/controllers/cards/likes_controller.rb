# frozen_string_literal: true

class Cards::LikesController < ApplicationController
  include Likable

  private

  def find_likable!
    @likable = Card.find(params[:card_id])
  end
end
