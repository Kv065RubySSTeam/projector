# frozen_string_literal: true

# Comment can be created/edited/updated/deleted
# Comments can be viewed with pagination
# @note Response to JS only
class CommentsController < ApplicationController
  # @!group Permissions
  load_and_authorize_resource :comment, except: [:create]
  # @!endgroup

  # @!group Callbacks
  before_action :find_column!
  before_action :find_comment!, only: %i[edit update destroy]
  before_action :find_card!
  before_action :flash_clear, except: [:edit]
  # @!endgroup

  respond_to :js

  # Returns set of comments
  # @action GET
  # @url /boards/:board_id/columns/:column_id/cards/:card_id/comments
  # @optional [Integer] page indicates which page to show
  # @response [Card] @card the requested [card], where the comment located
  # @response [Set<Comments>] @comments the set of comments
  def index
    @comments = @card.comments.order(created_at: :desc).paginate(page: params[:page])
  end

  # @note Comment can be created only if user has permissions for board, where card is located
  # Create a comment on the current board, current column, current card from the current user
  # Send email to the card creator, if he receives emails
  # @action POST
  # @url /boards/:board_id/columns/:column_id/cards/:card_id/comments
  # @return [Flash, Comment] flash with success message or error's string
  # and comment object
  def create
    @comment = @card.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      NotificationJobs::CreateNotification.perform_later(
        'AddCommentNotificationService', @comment
      )
      flash[:success] = 'Comment was successfully created.'
    else
      flash[:error] = @comment.errors.full_messages.join("\n")
      render status: 422
    end
  end

  # Returns form to edit comment
  # @note Only creator of comment can edit the comment
  # @url /boards/:board_id/columns/:column_id/cards/:card_id/comments/:id/edit
  # @required [Integer] id Identifier the comment
  # @action GET
  def edit; end

  # @note Comment can be created only if user has permissions for board, where card is located
  # Update comment body
  # @action PATCH
  # @url /boards/:board_id/columns/:column_id/cards/:card_id/comments/:id
  # @required [Integer] id Identifier the comment
  # @required [String] body
  # @return [Flash, Comment, String] flash with success message or error's string,
  #   previous body string and comment object
  def update
    if @comment.update(comment_params)
      flash[:success] = 'Comment was successfully updated.'
    else
      flash[:error] = @comment.errors.full_messages.join("\n")
      render status: 422
    end
  end

  # @note Comment can be created only if user has permissions for board, where card is located
  # @note Only creator of comment can delete the comment
  # Permanently delete the comment
  # @action DELETE
  # @url /boards/:board_id/columns/:column_id/cards/:card_id/comments/:id
  # @return [Flash, Comment] flash with success message or error's string,
  # and comment object
  def destroy
    if @comment.destroy
      flash[:success] = 'Comment was successfully deleted.'
    else
      flash[:error] = @comment.errors.full_messages.join("\n")
      render status: 422
    end
  end

  private

  # @!group Callbacks
  # @note Used for edit, update and destroy comment
  # Find comment through query params
  # @return [Comment]
  def find_comment!
    @comment = Comment.find(params[:id])
  end

  # Find column through query params
  # @return [Column]
  def find_column!
    @column = Column.find(params[:column_id])
  end

  # Find card through query params
  # @return [Card]
  def find_card!
    @card = Card.find(params[:card_id])
  end

  # Clear Flash cache so the past flashes won't appear during ajax responses
  # @return [void]
  def flash_clear
    flash.clear
  end
  # @!endgroup

  # Strong params that requer comment body
  # @return [String] comment body
  def comment_params
    params.require(:comment).permit(:body)
  end
end
