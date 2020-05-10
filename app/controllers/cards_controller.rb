class CardsController < ApplicationController

  before_action :find_column!
  before_action :find_card!, only: [:update, :edit, :destroy]
  before_action :flash_clear, except: :new
  
  def show; end

  def new; end

  def edit
    @comments = @card.comments.order(created_at: :desc).paginate(page: 1)
  end

  def create
    @card = @column.cards.build(card_params)
    @card.user = current_user
    respond_to do |f|   
      if @card.save
        f.js { flash[:success] = "Card was successfully created." }
      else
        f.js { flash[:error] = @card.errors.full_messages.join("\n") }
      end
    end
  end

  def update
    @card.update(card_params)
    respond_to do |f|
      if @card.valid?
        f.js { flash[:success] = "Card was successfully updated." }
      else
        f.js { flash[:error] = @card.errors.full_messages.join("\n") }
      end
    end
  end

  def destroy
    respond_to do |f|
      if @card.destroy
        f.js { flash[:success] = "Card was successfully deleted!" }
      else
        f.js { flash[:error] = @card.errors.full_messages.join("\n") }
      end
    end
  end

  private
  def find_card!
    @card = @column.cards.find(params[:id])
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
