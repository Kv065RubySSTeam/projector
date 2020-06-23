# frozen_string_literal: true

class CardsController < ApplicationController
  load_and_authorize_resource :column
  load_and_authorize_resource :card, through: :column,
                                     except: %i[index update_position]
  before_action :find_column!, except: :index
  before_action :find_card!, except: %i[index new create]
  before_action :flash_clear, except: :new
  before_action :find_board!, only: [:update]
  helper_method :sort_column, :sort_direction, :sort_filter
  before_action :find_user_by_email!, only: %i[add_assignee]
  respond_to :js

  # @note Renders card form, template for new card
  # @url /boards/:board_id/columns/:column_id/cards/new
  # @action GET
  #   @param id unique identifier of board, identifier of current colum
  #   @return a form for creation of a new board
  def new; end

  # @note Returns a set of cards from all boards, where current user is a member - connected to board through membership
  # @url /cards
  # @action GET
  # @return a set of exisitng(kept or non-discarded) cards according to the current page, available for current user, with 10 cards per page pagination sorted by updated_at field, desc
  def index
    @load_new = params[:load_new] || false
    @cards = Card.available_for(current_user)
                 .search(params[:search])
                 .order(sort_column + ' ' + sort_direction)
                 .filter(params[:filter], current_user)
                 .filter_by_board(params[:board_title])
    paginate_cards
  end

  # @note Renders the edit form for card - with editable title, board, list of tags, assignee and comments of the current card, sorted by created_at column, desc with 5 comments per page pagination and button for indefinite scroll
  # @url /boards/:board_id/columns/:column_id/cards/:id/edit
  # @action GET
  #   @param id unique identifier of board, column and card
  #   @return a form for card edit
  def edit
    @comments = @card.comments.order(created_at: :desc).paginate(page: 1)
  end

  # @note Creates a new card at the concrete board and column, assignes current user as card user
  # @url /boards/:board_id/columns/:column_id/cards
  # @action POST
  #   @param id unique identifier of board and column + body of the request should contain title of the card - at least 2 symbols and body - non obligatory
  #   @return flash - with success or error message and status 200 or 422
  def create
    @card = @column.cards.build(card_params)
    @card.user = current_user

    if @card.save
      flash[:success] = 'Card was successfully created.'
    else
      flash[:error] = @card.errors.full_messages.join("\n")
      render status: 422
    end
  end

  # @note Updates a concrete card - sends patch request to server with updated or current title and body
  # @url /boards/:board_id/columns/:column_id/cards/:id
  # @action PATCH
  #   @param id unique identifier of board, column and card + body of the request should contain current or updated title and body of the card
  #   @return flash - with success or error message and status 200 or 422
  def update
    if @card.update(card_params)
      flash[:success] = 'Card was successfully updated.'
    else
      flash[:error] = if @card.errors.full_messages.to_s.match(/Duration/)
                        'Duration is invalid (minimum 1 number, maximum 31d)'
                      else
                        @card.errors.full_messages.join("\n")
                      end
      render status: 422
    end
  end

  # @note Updates position of the card inside column. Accepts two arrays, which represent an expected order of card positions inside the column
  # @url /boards/:board_id/columns/:column_id/cards/:id/update_position
  # @action PUT
  #   @param id unique identifier of board, column and card + body of the request should contain two arrays of card positions inside the column
  #   @return flash - with success or error message
  def update_position
    result, errors = Cards::UpdatePositionService.call(
      @card, @column, params[:target_cards_id], params[:source_cards_id]
    )
    respond_to do |f|
      if result
        f.js { flash[:success] = 'Cards positions was successfully updated.' }
      else
        f.js { flash[:error] = errors.join("\n") }
      end
    end
  end

  # @note Discards card - changes field discarded_at inside card from nil to Date.now
  # @url /boards/:board_id/columns/:column_id/cards/:id
  # @action DELETE
  #   @param id unique identifier of board, column and card
  #   @return flash - with success or error message and status 200 or 422
  def destroy
    if @card.discard
      NotificationJobs::CreateNotification.perform_later(
        'DestroyCardNotificationService', @card
      )
      flash[:success] = 'Card was successfully deleted!'
    else
      flash[:error] = @card.errors.full_messages.join("\n")
      render status: 422
    end
  end

  # @note Assignes member of the board to the card adding user's id to assignee_id inside card and send notification by email
  # @url /boards/:board_id/columns/:column_id/cards/:id/add_assignee
  # @action POST
  #   @param id unique identifier of board, column and card + body of the request should contain email of the board member, that should be added to the card
  #   @return flash - with success or error message and status
  def add_assignee
    membership = @column.board.memberships.find_by(user: @user)

    unless membership
      render json: { error: 'User is not a member of this board' }, status: 404
      return
    end
    if @card.assign!(@user)
      NotificationJobs::CreateNotification.perform_later(
        'AddAssigneeNotificationService', @card
      )
      render json: {}, status: 200
    else
      render json: { error: @card.errors.full_messages }, status: 422
    end
  end

  # @note Removes assignee from the card - changes card.assignee field to nil
  # @url /boards/:board_id/columns/:column_id/cards/:id/remove_assignee
  # @action DELETE
  #   @param id unique identifier of board, column and card
  #   @return flash - with success or error message and status
  def remove_assignee
    if @card.remove_assign!
      flash[:success] = 'Assignee was successfully deleted!'
    else
      flash[:error] = @card.errors.full_messages.join("\n")
    end
  end

  private

  def find_card!
    @card = Card.find(params[:id])
  end

  def find_board!
    @board = Board.find(params[:board_id])
  end

  def find_column!
    @column = Column.find(params[:column_id])
  end

  def find_user_by_email!
    @user = User.find_by(email: params[:email])
    render json: { error: 'User doesn\'t exist' }, status: 404 unless @user
  end

  def card_params
    params.require(:card).permit(:title, :body, :start_date, :duration)
  end

  def flash_clear
    flash.clear
  end

  def sort_column
    params[:sort] || 'updated_at'
  end

  def sort_direction
    params[:direction] || 'desc'
  end

  def sort_filter
    params[:filter] || 'saved'
  end

  protected

  def paginate_cards
    if @load_new
      @cards = @cards.limit(Card.per_page * params[:page].to_i)
      @current_page = params[:page].to_i
      @total_pages = (Card.available_for(current_user).count / Card.per_page.to_f).ceil
    else
      @cards = @cards.paginate(page: params[:page])
      @current_page = @cards.current_page
      @total_pages = @cards.total_pages
    end
  end
end
