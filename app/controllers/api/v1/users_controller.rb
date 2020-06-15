module Api
  module V1
    class UsersController < BaseController
      skip_before_action :require_login, only: %i[create]
     
      def index
        users = User.search(params[:search]).limit(10)
        render :index, locals: { users: users }
      end
      
      def create
        user = User.new(user_params)
        if user.save
          token =  Users::CreateTokenService.call(user)
          render partial: 'api/v1/users/user', locals: { user: user }, status: 201
          response.set_header('Authorization: Bearer', token)
        else
          render json: { errors: user.errors.full_messages }, status: 422
        end
      end

      def show
        render partial: 'api/v1/users/user', locals: { user: session_user }, status: 200
      end

      private

      def user_params
        params.permit(:email, :password, :first_name, :last_name)
      end

    end
  end
end
