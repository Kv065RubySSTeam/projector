class CommentsController < ApplicationController
  before_action :find_column!
  before_action :find_comment!, only: [:edit, :update, :destroy]
  before_action :find_card!, except: [:new]
  before_action :flash_clear, except: [:new, :edit]
  respond_to :js

  def index
    @comments = @card.comments.order(created_at: :desc).paginate(page: params[:page])
  end

  def create
    @comment = @card.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      email_receivers(@card).each do |user|
        CardMailer.with(card: @card, user: user).added_comment.deliver_later if user.receive_emails
      end
      flash[:success] = "Comment was successfully created." 
    else
      flash[:error] = @comment.errors.full_messages.join("\n") 
    end
  end

  def edit; end

  def update
    if @comment.update(comment_params)
      flash[:success]  = "Comment was successfully updated." 
    else
      flash[:error] = @comment.errors.full_messages.join("\n") 
    end
  end

  def destroy
    if @comment.destroy
      flash[:success]  = "Comment was successfully deleted." 
    else
      flash[:error] = @comment.errors.full_messages.join("\n") 
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

  def email_receivers(card)
    [card.user, card.assignee].compact
  end

end
