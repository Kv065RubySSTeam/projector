module Api
  module V1
    class PasswordController < BaseController
      skip_before_action :require_login
      before_action :find_user_by_email!, only: %i[new]

      def new
        @user.update({ reset_password_token: SecureRandom.uuid, reset_password_sent_at: Time.now})

        PasswordMailer.with(user: @user).reset_password.deliver_later
        render json: { success: 'Successfully sended email.' }, status: 200
      end

      def edit
        @user = User.with_active_reset_password(params[:reset_password_token])
        
        if params[:new_password].present? && params[:new_password] == params[:new_password_confirmation]
          @user.reset_password(params[:new_password], params[:new_password_confirmation])

          @user.update({ reset_password_token: nil, reset_password_sent_at: nil })

          token = Users::CreateTokenService.call(@user)
          render partial: 'api/v1/users/user', locals: { user: @user }, status: 201
          response.set_header('Authorization: Bearer', token)
        else
          render json: { error: 'Password confirmation doesn\'t match Password.' }, status: 422
        end
      end
      
      private 

      def find_user_by_email!
        @user = User.find_by!(email: params[:email])
        render json: { error: 'User doesn\'t exist' }, status: 404 unless @user
      end

    end
  end
end
