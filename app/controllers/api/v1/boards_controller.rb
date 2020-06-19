module Api
  module V1
    class BoardsController < Api::V1::BaseController
      load_and_authorize_resource :board, except: [:create, :export, :members]
      before_action :find_board!, except: %i[index create]
      respond_to :json

      def index
        # need to be deleted, when current_user method will be available
        user = User.find(params[:user_id])

        @boards = Board.includes(:user)
          .filter(params[:filter], user)
          .search(params[:search])
          .sorting(params[:sort])
          .paginate(page: params[:page])
      end

      def show; end

      def create
        # need to be deleted, when current_user method will be available
        user = User.find(params[:board][:user_id])

        @board = Boards::CreateService.call(user, board_params)
        if @board.errors.empty?
          render partial: 'board', object: @board, status: 201
        else
          render json: { errors: @board.errors.full_messages }, status: 422
        end
      end

      def update
        if @board.update(board_params)
          render partial: 'board', object: @board, status: 200
        else
          render json: { errors: @board.errors.full_messages }, status: 422
        end
      end

      def destroy
        if @board.destroy
          render json: { message: 'Successfully deleted!' }, status: 200
        else
          render json: { errors: @board.errors.full_messages }, status: 422
        end
      end

      def members; end

      private

      def find_board!
        @board = Board.find(params[:id])
      end

      def board_params
        params.require(:board).permit(:title, :description, :public)
      end
    end
  end
end
