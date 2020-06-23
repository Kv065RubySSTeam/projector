# frozen_string_literal: true

module Api
  module V1
    class UsersController < BaseController
      skip_before_action :authenticate!, only: %i[create]

      def index
        @users = User.search(params[:search]).limit(10)
      end

      def create
        @user = User.new(user_params)
        if @user.save
          generate_token_and_set_to_header(@user)
          render :show, status: 201
        else
          render json: { errors: @user.errors.full_messages }, status: 422
        end
      end

      def show; end

      private

      def user_params
        params.permit(:email, :password, :first_name, :last_name)
      end
    end
  end
end
