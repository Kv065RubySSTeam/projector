class CardsController < ApplicationController
  load_and_authorize_resource :column
  load_and_authorize_resource :card, through: :column,
                                  except: [:index, :update_position]
  before_action :find_column!, except: :index
  before_action :find_card!, except: %i[index new create]
  before_action :flash_clear, except: :new
  before_action :find_board!, only: [:update]
  helper_method :sort_column, :sort_direction, :sort_filter
  before_action :find_user_by_email!, only: %i[add_assignee]
  respond_to :js

  def new; end

  def index
    @load_new = params[:load_new] || false
    @cards = Card.kept
                 .available_for(current_user)
                 .search(params[:search])
                 .order(sort_column + " " + sort_direction)
                 .filter(params[:filter], current_user)
                 .filter_by_board(params[:board_title])
    paginate_cards
  end

  def edit
    @comments = @card.comments.order(created_at: :desc).paginate(page: 1)
  end

  def create
    @card = @column.cards.build(card_params)
    @card.user = current_user

    if @card.save
      flash[:success] = "Card was successfully created."
    else
      flash[:error] = @card.errors.full_messages.join("\n")
    end
  end

  def update
    if @card.update(card_params)
      flash[:success] = "Card was successfully updated."
    else
      flash[:error] = @card.errors.full_messages.join("\n")
    end
  end

  def update_position
    result, errors = Cards::UpdatePositionService.call(
      @card, @column, params[:target_cards_id], params[:source_cards_id])
    respond_to do |f|
      if result
        f.js { flash[:success] = "Cards positions was successfully updated." }
      else
        f.js { flash[:error] = errors.join("\n") }
      end
    end
  end

  def destroy
    if @card.discard
      flash[:success] = "Card was successfully deleted!"
    else
      flash[:error] = @card.errors.full_messages.join("\n")
    end
  end

  def add_assignee
    membership = @column.board.memberships.find_by(user: @user)

    unless membership
      render json: { error: 'User is not a member of this board' }, status: 404
      return
    end
    if @card.assign!(@user)
      @card.notification_receivers.each do |user|
        CardMailer.with(card: @card, user: user).new_assignee.deliver_later if user.receive_emails
      end
      render json: {}, status: 200
    else
      render json: { error: @card.errors.full_messages }, status: 422
    end
  end

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
    params.require(:card).permit(:title, :body)
  end

  def flash_clear
    flash.clear()
  end

  def sort_column
    params[:sort] || "updated_at"
  end

  def sort_direction
    params[:direction] || "desc"
  end

  def sort_filter
    params[:filter] || "saved"
  end

  protected

  def paginate_cards
    if @load_new
      @cards = @cards.limit(Card.per_page * params[:page].to_i)
      @current_page = params[:page].to_i
      @total_pages = (Card.available_for(current_user).count() / Card.per_page.to_f).ceil
    else
      @cards = @cards.paginate(page: params[:page])
      @current_page = @cards.current_page
      @total_pages = @cards.total_pages
    end
  end
  
end
