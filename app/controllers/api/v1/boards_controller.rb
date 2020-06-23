# frozen_string_literal: true

module Api
  module V1
    class BoardsController < Api::V1::BaseController
      load_and_authorize_resource :board, except: %i[create export members]
      before_action :find_board!, except: %i[index create]

      def index
        @boards = Board.includes(:user)
                       .filter(params[:filter], current_user)
                       .search(params[:search])
                       .sorting(params[:sort])
                       .paginate(page: params[:page])
      end

      def show; end

      def create
        @board = Boards::CreateService.call(current_user, board_params)
        if @board.errors.empty?
          render :show, status: 201
        else
          render json: { errors: @board.errors.full_messages }, status: 422
        end
      end

      def update
        if @board.update(board_params)
          render :show, status: 200
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
