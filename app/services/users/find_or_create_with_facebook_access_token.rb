module Users
  class FindOrCreateWithFacebookAccessToken < ApplicationService
    attr_accessor :oauth_access_token

    def initialize(oauth_access_token)
      @oauth_access_token = oauth_access_token
    end
  
    def call
      graph = Koala::Facebook::API.new(oauth_access_token)
      profile = graph.get_object('me', fields: ['first_name', 'last_name', 'email'])
  
      data = {
        email: profile['email'],
        first_name: profile['first_name'],
        last_name: profile['last_name'],
        uid: profile['id'],
        provider: 'facebook',
        password: SecureRandom.urlsafe_base64
      }
  
      if (user = User.find_by(uid: data['uid'], provider: 'facebook'))
        user.update_attributes(data)
      else
        User.create(data)
      end
    end

  end
end
