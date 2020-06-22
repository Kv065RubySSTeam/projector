require 'rails_helper'

RSpec.describe Users::CreateTokenService do
  let!(:user) { create(:user) }
  let!(:create_service) { Users::CreateTokenService.new(user) }

  describe "#call" do
    subject { create_service.call() }

    context 'token for user are correctly set' do
      it 'create user jti params' do
        subject
        expect( user.jti ).not_to be_nil
      end
      it 'new tokens are valid' do
        expect { JWT.decode(subject,
                            Rails.application.secrets.secret_key_base,
                            true,
                            algorithm: 'HS256') 
               }.to_not raise_error(JWT::DecodeError)
      end
    end

  end
end
