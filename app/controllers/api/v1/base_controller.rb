# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate!
      rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found_error
      rescue_from CanCan::AccessDenied, with: :handle_access_denied_error
      respond_to :json

      protected

      def auth_header
        request.headers['Authorization']
      end

      def generate_token_and_set_to_header(user)
        token = Users::CreateTokenService.call(user)
        response.set_header('Authorization: Bearer', token)
      end

      def current_user
        @user = Users::DecryptTokenService.call(auth_header)
      end

      def logged_in?
        current_user.present?
      end

      def authenticate!
        render json: { message: 'Please Login' }, status: 401 unless logged_in?
      end

      private

      def handle_record_not_found_error(e)
        render json: { error: e.to_s }, status: 404
      end

      def handle_access_denied_error(e)
        render json: { error: e.to_s }, status: 401
      end
    end
  end
end
