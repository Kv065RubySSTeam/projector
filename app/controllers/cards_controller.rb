class CardsController < ApplicationController
  before_action :find_card!, only: :update
  before_action :find_column!
  before_action :flash_clear, except: [:new, :edit]
  
  def show; end
  
  def new; end

  def edit; end

  def create
    @card = @column.cards.build(card_params)
    @card.user = current_user
    @card.position = @column.cards.last_position

    respond_to do |f|  
      if @card.save
        f.js { flash[:success] = "Card was successfully created." }
      else
        f.js { flash[:error] = "With creatind card were an error!" }
      end
    end
  end

  def update
  end

  def destroy
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
