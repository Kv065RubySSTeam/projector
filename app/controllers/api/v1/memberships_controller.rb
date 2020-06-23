# frozen_string_literal: true

module Api
  module V1
    class MembershipsController < Api::V1::BaseController
      before_action :find_board!
      before_action :find_user!
      before_action :membership_authorize!
      before_action :find_membership!, only: %i[admin]

      def create
        @membership = @board.memberships.create(user: @new_member)

        if @membership.errors.empty?
          render json: { message: 'Successfully created membership!' }, status: 201
        else
          render json: { errors: @membership.errors.full_messages }, status: 422
        end
      end

      def admin
        @membership.admin? ? @membership.remove_admin! : @membership.admin!

        if @membership.errors.empty?
          render json: { message: 'Successfully changed admin rights!' }, status: 200
        else
          render json: { errors: @membership.errors.full_messages }, status: 422
        end
      end

      private

      def find_board!
        @board = Board.find(params[:board_id])
      end

      def find_membership!
        @membership = @board.memberships.find_by!(user: @new_member)
      end

      def find_user!
        @new_member = User.find(params[:user_id])
      end

      def membership_authorize!
        render json: { error: 'Unauthorize' }, status: 401 unless current_user.administrated_boards.exists?(@board.id)
      end
    end
  end
end
