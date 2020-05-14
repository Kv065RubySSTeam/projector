class CardsController < ApplicationController
  before_action :find_column!
  before_action :find_card!, only: [:edit, :update, :update_position, :destroy]
  before_action :flash_clear, except: :new
  respond_to :js
  
  def new; end

  def edit
    @comments = @card.comments.order(created_at: :desc).paginate(page: 1)
  end

  def create
    @card = @column.cards.build(card_params)
    @card.user = current_user

    if @card.save
      flash[:success] = "Card was successfully created."
    else
      flash[:error] = @card.errors.full_messages.join("\n")
    end
  end

  def update
    if @card.update(card_params)
      flash[:success] = "Card was successfully updated."
    else
      flash[:error] = @card.errors.full_messages.join("\n")
    end
  end

  def update_position
    result, errors = Cards::UpdatePositionService.call(
      @card, @column, params[:target_cards_id], params[:source_cards_id])
    respond_to do |f|
      if result
        f.js { flash[:success] = "Cards positions was successfully updated." }
      else
        f.js { flash[:error] = errors.join("\n") }
      end
    end
  end

  def destroy
    if @card.destroy
      flash[:success] = "Card was successfully deleted!"
    else
      flash[:error] = @card.errors.full_messages.join("\n")
    end
  end

  private
  def find_card!
    @card = Card.find(params[:id])
  end

  def find_column!
    @column = Column.find(params[:column_id])
  end

  def card_params
    params.require(:card).permit(:title, :body)
  end

  def flash_clear
    flash.clear()
  end
end
