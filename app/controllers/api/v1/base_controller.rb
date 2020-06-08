module Api
  module V1
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found_error
      rescue_from CanCan::AccessDenied, with: :handle_access_denied_error

      private

      def handle_record_not_found_error(e)
        render json: { error: e.to_s }, status: :not_found
      end

      def handle_access_denied_error(e)
        render json: { error: e.to_s }, status: :unauthorized
      end
    end
  end
end
