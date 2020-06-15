require 'koala'
module Api
  module V1
    class FacebookAuthenticationsController < BaseController

      skip_before_action :require_login

      respond_to :json
    
      def create
        facebook_access_token = params.require(:facebook_access_token)
        user = Users::FindOrCreateWithFacebookAccessToken.call(facebook_access_token)
        
        if user.persisted?
          user.update( jti: SecureRandom.uuid )
          token = Users::CreateTokenService.call(user)
          render partial: 'api/v1/users/user', locals: { user: user }, status: 201
          response.set_header('Authorization: Bearer', token)
        else
          render json: user.errors, status: 422 
        end
      end
    end
  end
end
