module Api
  module V1
    class AuthenticationController < BaseController
      skip_before_action :require_login, only: %i[login auto_login]

      def login
        user = User.find_by(email: params[:email])

        if user && user.valid_password?(params[:password])
          token = Users::CreateTokenService.call(user)
          render partial: 'api/v1/users/user', locals: { user: user }, status: 200
          response.set_header('Authorization: Bearer', token)
        else
          render json: { error: 'Log in failed! Username or password invalid.' }, status: 401
        end
      end

      def auto_login
        if session_user
          render partial: 'api/v1/users/user', locals: { user: user }, status: 200
        else
          render json: { error: 'User is not Logged In.' }, status: 401
        end
      end

      def user_is_authed
        render json: { message: 'You are authorized.' }, status: 200
      end
      
      def logout
        if logged_in?
          session_user.update_attribute(:jti, SecureRandom.uuid)
          render json: { message: 'Successfuly logout.'}, status: 200
        else 
          render json: { error: 'Unauthorize' }, status: 401
        end
      end      
    end
  end
end
