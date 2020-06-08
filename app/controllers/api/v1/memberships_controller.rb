module Api
  module V1
    class MembershipsController < Api::V1::BaseController
      before_action :find_board!
      before_action :find_user!
      before_action :membership_authorize!
      before_action :find_membership!, only: %i[admin]
      respond_to :json

      def create
        @membership = @board.memberships.create(user: @user)

        if @membership.errors.empty?
          render partial: 'membership', object: @membership, status: 201
        else
          render json: { errors: @membership.errors.full_messages }, status: 422
        end
      end

      def admin
        @membership.admin? ? @membership.remove_admin! : @membership.admin!

        if @membership.errors.empty?
          render partial: 'membership', object: @membership, status: 200
        else
          render json: { errors: @membership.errors.full_messages }, status: 422
        end
      end

      private

      def find_board!
        @board = Board.find(params[:board_id])
      end

      def find_membership!
        @membership = @board.memberships.find_by!(user: @user)
      end

      def find_user!
        @user = User.find(params[:user_id])
      end

      def membership_authorize!
        # need to be deleted, when current_user method will be available
        current_user = @board.user

        unless current_user.administrated_boards.exists?(@board.id)
          render json: { error: 'Unauthorize' }, status: 401
        end
      end
    end
  end
end
