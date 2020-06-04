class CommentsController < ApplicationController
  load_and_authorize_resource :comment, except: [:create]
  before_action :find_column!
  before_action :find_comment!, only: [:edit, :update, :destroy]
  before_action :find_card!
  before_action :flash_clear, except: [:edit]
  respond_to :js

  def index
    @comments = @card.comments.order(created_at: :desc).paginate(page: params[:page])
  end

  def create
    @comment = @card.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      @card.notification_receivers.each do |user|
        CardMailer.with(card: @card, user: user).added_comment.deliver_later if user.receive_emails
      end
      flash[:success] = "Comment was successfully created." 
    else
      flash[:error] = @comment.errors.full_messages.join("\n")
      render status: 422 
    end
  end

  def edit; end

  def update
    if current_user == @comment.user
      if @comment.update(comment_params)
        flash[:success]  = "Comment was successfully updated." 
      else
        flash[:error] = @comment.errors.full_messages.join("\n")
        render :nothing => true, :status => :unprocessable_entity
      end
    else
      flash[:error] = @comment.errors.full_messages.join("\n")
      render status: 422
    end
  end

  def destroy
    if current_user == @comment.user
      if @comment.destroy
        flash[:success]  = "Comment was successfully deleted." 
      else
        flash[:error] = @comment.errors.full_messages.join("\n")
        render :nothing => true, :status => :unprocessable_entity
      end
    else
      flash[:error] = @comment.errors.full_messages.join("\n")
      render status: 422
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
