# frozen_string_literal: true

module Users
  class FindOrCreateWithFacebookAccessTokenService < ApplicationService
    attr_accessor :oauth_access_token

    def initialize(oauth_access_token)
      @oauth_access_token = oauth_access_token
    end

    def call
      user = profile_info
      (user.is_a? User) ? user : create_user(user)
    end

    private

    def create_user(user)
      data = get_user_data(user)
      if (user = User.find_by(uid: data['uid'], provider: 'facebook'))
        user.update_attributes(data)
      else
        User.create(data)
      end
    end

    def profile_info
      graph = Koala::Facebook::API.new(oauth_access_token)
      graph.get_object('me', fields: %w[first_name last_name email])
    rescue Koala::Facebook::APIError => e
      user = User.new
      user.errors[:base] << e.fb_error_message
      user
    end

    def get_user_data(profile)
      {
        email: profile['email'],
        first_name: profile['first_name'],
        last_name: profile['last_name'],
        uid: profile['id'],
        provider: 'facebook',
        password: SecureRandom.urlsafe_base64
      }
    end

    def koala_graph
      graph = Koala::Facebook::API.new(oauth_access_token)
      profile = graph.get_object('me', fields: %w[first_name last_name email])
    end
  end
end
