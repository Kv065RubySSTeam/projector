# frozen_string_literal: true

module Api
  module V1
    class ColumnsController < Api::V1::BaseController
      load_and_authorize_resource :board
      load_and_authorize_resource :column, except: %i[index create], through: :board
      before_action :find_board!
      before_action :find_column!, except: %i[index create]

      def index
        @columns = @board.columns.paginate(page: params[:page])
      end

      def show; end

      def create
        @column = Columns::CreateService.call(@board, current_user)

        if @column.errors.empty?
          render :show, status: 201
        else
          render json: { errors: @column.errors.full_messages }, status: 422
        end
      end

      def update
        if @column.update(update_param)
          render :show, status: 200
        else
          render json: { errors: @column.errors.full_messages }, status: 422
        end
      end

      def destroy
        if @column.destroy
          render json: { message: 'Successfully deleted!' }, status: 200
        else
          render json: { errors: @column.errors.full_messages }, status: 422
        end
      end

      private

      def find_column!
        @column = @board.columns.find(params[:id])
      end

      def find_board!
        @board = Board.find(params[:board_id])
      end

      def update_param
        params.require(:column).permit(:name)
      end
    end
  end
end
