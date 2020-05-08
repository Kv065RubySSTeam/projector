class CommentsController < ApplicationController
  before_action :find_column!
  before_action :find_comment!, only: [:edit, :update, :destroy]
  before_action :find_card!, except: [:new]

  def new
    @card = Card.find(params[:id])  # Only here card id in params
  end
  
  def create
    @comment = @card.comments.build(comment_params)
    @comment.user = current_user
    
    respond_to do |f|   
      if @comment.save
        f.js { flash[:success] = "Comment was successfully created." }
      else
        f.js { flash[:error] = "With creatind comment were an error!" }
      end
    end
  end

  def edit; end

  def update
    @comment.update(comment_params)
    @comments = @card.comments.order(created_at: :desc)
  end
  
  def destroy
    @comment.destroy
  end

  private

  def find_comment!
    @comment = Comment.find(params[:id])
  end

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
