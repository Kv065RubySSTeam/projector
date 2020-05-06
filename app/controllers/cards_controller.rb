class CardsController < ApplicationController
  before_action :find_card!, only: :update
  before_action :find_column!
  before_action :find_board!
  before_action :flash_clear, except: [:new, :edit]
  
  def index; end
  def show; end

  def new
    # respond_to do |f|  
    #   f.js 
    # end
  end

  def edit; end

  def create
    last_position = @board.columns.maximum(:position)

    @card = @column.cards.build(card_param)
    @card.position =last_position.nil? ? 1 : last_position + 1
    @card.user_id = current_user.id

    respond_to do |f|
      if @column.save
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
    @column = Card.find(params[:id])
  end

  def find_column!
    @column = Column.find(params[:column_id])
  end

  def find_board!
    @board = Board.find(params[:board_id])
  end

  def card_param
    params.require(:card).permit(:title, :body)
  end

  def flash_clear
    flash.clear()
  end

end
