# frozen_string_literal: true

module Users
  class DecryptTokenService < ApplicationService
    attr_accessor :auth_header

    def initialize(auth_header)
      @auth_header = auth_header
    end

    def call
      decoded_hash = decoded_token
      return if decoded_hash.nil?

      user_id = decoded_hash[0]['user_id']
      exp = decoded_hash[0]['exp']
      jti = decoded_hash[0]['jti']
      user = User.find_by(id: user_id)
      user if exp > Time.now.to_i && jti == user.jti
    end

    private

    def decoded_token
      if auth_header
        token = auth_header.split(' ')[1]
        begin
          JWT.decode(token, Rails.application.secrets.secret_key_base, true, algorithm: 'HS256')
        rescue JWT::DecodeError
          nil
        end
      end
    end
  end
end
