class CommentsController < ApplicationController
  before_action :find_column!
  before_action :find_card!, except: [:new]

  def new
    @card = Card.find(params[:id])
  end
  
  def create
    @comment = @card.comments.build(comment_params)
    @comment.user = current_user
    @comment.save
  end

  def edit
  end
  
  def destroy
    @comment = @card.comments.find(params[:id])
    @comment.destroy
  end

  private

  def find_column!
    @column = Column.find(params[:column_id])
  end

  def find_card!
    @card = Card.find(params[:card_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
