# frozen_string_literal: true

require 'koala'
module Api
  module V1
    class FacebookAuthenticationsController < BaseController
      skip_before_action :authenticate!

      def create
        facebook_access_token = params.require(:facebook_access_token)
        @user = Users::FindOrCreateWithFacebookAccessTokenService.call(facebook_access_token)

        if @user.errors.empty?
          generate_token_and_set_to_header(@user)
          render :show, status: 201
        else
          render json: { errors: @user.errors.messages }, status: 422
        end
      end
    end
  end
end
