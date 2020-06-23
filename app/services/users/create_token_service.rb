# frozen_string_literal: true

module Users
  class CreateTokenService < ApplicationService
    attr_accessor :user

    def initialize(user)
      @user = user
    end

    def call
      user.update_attribute(:jti, SecureRandom.uuid)
      time = Time.now.to_i + 4 * 3600
      payload = { user_id: user.id, exp: time, jti: user.jti }
      token = JWT.encode(payload, Rails.application.secrets.secret_key_base)
    end
  end
end
