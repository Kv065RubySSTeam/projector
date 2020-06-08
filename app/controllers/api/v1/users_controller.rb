module Api
  module V1
    class UsersController < BaseController
      skip_before_action :require_login, only: %i[create]

      def create
        user = User.create(user_params)
        if user.valid?
          payload = { user_id: user.id }
          token = encode_token(payload)
          render json: { user: user, jwt: token }
        else
          render json: { errors: user.errors.full_messages }, status: :not_acceptable
        end
      end

      private

      def user_params
        params.permit(:email, :password)
      end
    end
  end
end
