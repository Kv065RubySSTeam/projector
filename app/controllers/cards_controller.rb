class CardsController < ApplicationController
  before_action :find_card!, only: [:update, :edit]
  before_action :find_column!
  before_action :flash_clear, except: [:new, :edit]
  
  def show; end
  
  def new; end
  
  def edit
    @comments = @card.comments.order(created_at: :desc)
  end

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
    @card.update(card_params)
    if @card.valid?
      respond_to do |f|
        f.js { flash[:success] = "Card was successfully updated." }
      end
    else
      flash[:error] = @card.errors.full_messages.join("\n")
    end
  end

  def destroy
    @card = @column.cards.find(params[:id])
    respond_to do |f|
      if @card.destroy
        f.js { flash[:success] = "Card was successfully deleted!" } 
      else
        flash[:error] = "Something went wrong, the card wasn't deleted"
      end
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
    params.require(:card).permit(:title, :body )
  end

  def flash_clear
    flash.clear()
  end

end