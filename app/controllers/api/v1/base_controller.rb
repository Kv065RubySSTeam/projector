module Api
  module V1
    class BaseController < ActionController::API
      before_action :require_login
      rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found_error
      rescue_from CanCan::AccessDenied, with: :handle_access_denied_error

      protected

      def auth_header
        request.headers['Authorization']
      end

      def session_user
        user = Users::DecryptTokenService.call(auth_header)
      end

      def logged_in?
        session_user.present?
      end

      def require_login
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
