module Api
  module V1
    class CardsController < Api::V1::BaseController
    # load_and_authorize_resource :column
    # load_and_authorize_resource :card, through: :column,
    #                              except: [:index, :update_position]
      before_action :find_column!, except: :index
      before_action :find_card!, except: %i[index new create]
      before_action :find_board!, only: [:update]
      helper_method :sort_column, :sort_direction, :sort_filter
      before_action :find_user_by_email!, only: %i[add_assignee]
      # before_action :find_user!, only: %i[index, show]
      before_action :find_membership!, only: [:add_assignee]
      #?page=1
      def index
      #FIXME: user is not available
        current_user = User.find(1)
        @load_new = params[:load_new] || false
        @cards = Card.kept
                .available_for(current_user)
                .search(params[:search])
                .order(sort_column + " " + sort_direction)
                .filter(params[:filter], current_user)
                .filter_by_board(params[:board_title])
                paginate_cards
        render :index, status: 200
      end

      def show
        if @card.errors.empty?
          render :show, status: 200
        else
          @error_message = @card.errors.full_messages
          render :error_message, status: 422
        end
      end

      # "user_id": 2
      def create
        @card = @column.cards.build(card_params)
        if @card.save
          render :show, status: 200
        else
          @error_message = @card.errors.full_messages
          render :error_message, status: 422
        end
      end

      def update
        if @card.update(card_params)
          render :show, status: 200
        else
          @error_message = @card.errors.full_messages
          render :error_message, status: 422
        end
      end

      # { "target_cards_id": "[8,4,9,10]","source_cards_id": "[5,6,7]" }
      # { "target_cards_id": "[8,4,9,10]","source_cards_id": "[]" }
      def update_position
        result, errors = Cards::UpdatePositionService.call(@card, @column, params[:target_cards_id], params[:source_cards_id])
        if result
          @message = 'Card position was successfully updated'
          render :success_message, status: 200
        else
          @error_message = errors.full_messages
          render :error_message, status: 422
        end
      end

      def destroy
        if @card.discard
          @message = 'Card was successfully discarded!'
          render :success_message, status: 200
        else
          @error_message = @card.errors.full_messages
          render :error_message, status: 422
        end
      end

      # { "email": "me@gmail.com" }
      def add_assignee
        unless @membership
          @error_message = 'User is not a member of this board'
          render :error_message, status: 404
          return
        end
        if @card.assign!(@user)
          @card.notification_receivers.each do |user|
            CardMailer.with(card: @card, user: user).new_assignee.deliver_later if user.receive_emails
          end
          render partial: 'api/v1/cards/assignee', status: 200
        else
          @error_message = @card.errors.full_messages
          render :error_message, status: 422
        end
      end

      #DELETE
      def remove_assignee
        if @card.remove_assign!
          @message = 'Assignee was successfully deleted!'
          render :success_message, status: 200
        else
          @error_message = @card.errors.full_messages
          render :error_message, status: 422
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

      def find_membership!
        #FIXME: user is not available
        current_user = User.find(1)
        @membership = @column.board.memberships.find_by(user: current_user)
        render json: { error: 'Membership doesn\'t exist' }, status: 404 unless @membership
      end

      def card_params
        params.require(:card).permit(:title, :body, :user_id)
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
  end
end
