require 'rails_helper'

RSpec.describe "Api::V1::Authentications", type: :request do

  let(:user) { create(:user, password: "password", password_confirmation: "password") }

  let(:valid_attributes) do
    attributes_for(:user, email: user.email, password: user.password )
  end

  let(:invalid_attributes) do
    attributes_for(:user, email: "invalid" )
  end

  describe "POST api/v1/login#login" do
    context "correct params are passed" do
      subject { post api_v1_login_path( params: valid_attributes, format: :json) }
      it "returns status 200" do
        subject
        expect(response).to have_http_status(200)
      end
      it "returns correct partial" do
        subject
        expect(response).to render_template(partial: '_user')
      end
      it "has header with new token" do
        subject
        expect(response.header["Authorization: Bearer"]).to be_present
      end
    end

    context "incorrect params are passed" do
      subject { post api_v1_login_path( params: invalid_attributes, format: :json) }
      it "returns status 200" do
        subject
        expect(response).to have_http_status(401)
      end
      it "returns correct error message" do
        subject
        expect(JSON.parse(response.body)['error']).to eq("Log in failed! Username or password invalid.")
      end
      it "hasn't token inside header" do
        subject
        expect(response.header["Authorization: Bearer"]).to_not be_present
      end
    end
  end

  describe "DELETE api/v1/authentication#logout" do
    let(:token_new) { Users::CreateTokenService.call(user) }
    let(:token) do
      {  "Authorization" => "Bearer #{token_new}"  }
    end
    context "correct params are passed" do
      subject { delete api_v1_logout_path(format: :json), headers: token }
      it "returns status 200" do
        subject
        expect(response).to have_http_status(200)
      end
      it "returns correct error message" do
        subject
        expect(JSON.parse(response.body)['message']).to eq('Successfuly logout.')
      end
    end

    context "incorrect params are passed" do
      let!(:token) do
        {  "Authorization" => "Bearer some_hash344sd4rtwesdf"  }
      end
      subject { delete api_v1_logout_path(format: :json), headers: token  }
      it "returns status 401" do
        subject
        expect(response).to have_http_status(401)
      end
      it "returns correct error message" do
        subject
        expect(JSON.parse(response.body)['message']).to eq('Please Login')
      end
    end
  end
end
