class CardsController < ApplicationController
  before_action :find_card!, only: :update
  before_action :find_column!
  
  def new
    # respond_to do |f|  
    #   f.js 
    # end
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

  def update_param
    params.require(:column).permit(:title, :body)
  end

end
