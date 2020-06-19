module Api
  module V1
    class ColumnsController < Api::V1::BaseController
      load_and_authorize_resource :board
      load_and_authorize_resource :column, except: :create, through: :board
      before_action :find_board!
      before_action :find_column!, except: %i[create]
      respond_to :json

      def create
        # need to be deleted, when current_user method will be available
        user = User.find(params[:column][:user_id])

        @column = Columns::CreateService.call(@board, user)

        if @column.errors.empty?
          render partial: 'column', object: @column, status: 201
        else
          render json: { errors: @column.errors.full_messages }, status: 422
        end
      end

      def update
        if @column.update(update_param)
          render partial: 'column', object: @column, status: 200
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
