class Cards::LikesController < ApplicationController
  include Likable

  before_action :find_likable!

  private
  def find_likable!
    @likable = Card.find_by(id: params[:card_id]) if params[:card_id]
  end
end