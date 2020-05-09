class CommentsController < ApplicationController
  before_action :find_column!
  before_action :find_comment!, only: [:edit, :update, :destroy]
  before_action :find_card!, except: [:new]
  before_action :flash_clear, except: [:new, :edit]

  def index
    @comments = @card.comments.order(created_at: :desc).paginate(page: params[:page])
  end

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
        f.js { flash[:error] = @comment.errors.full_messages.join("\n") }
      end
    end
  end

  def edit; end

  def update
    @comment.update(comment_params)
    respond_to do |f|
      if @comment.valid?
        f.js { flash[:success] = "Comment was successfully updated." }
      else
        f.js { flash[:error] = @comment.errors.full_messages.join("\n") }
      end
    end
  end

  def destroy
    respond_to do |f|
      if @comment.destroy
        f.js { flash[:success] = "Comment was successfully deleted." }
      else
        f.js { flash[:error] = @comment.errors.full_messages.join("\n") }
      end
    end
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

  def flash_clear
    flash.clear()
  end
end
