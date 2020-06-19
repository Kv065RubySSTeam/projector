require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  
  let(:user_params) do
    {
      "email": "anon@anon.com",
      "password": "password",
      "first_name": "Anonimus",
      "last_name": "Nope"
     }
    end
    
  let(:user) { create(:user, password: "password", password_confirmation: "password") }

  let(:valid_attributes) do
    attributes_for(:user, password: "password", email: user.email )
  end
  let(:token_new) { Users::CreateTokenService.call(user) }
  let(:token) do
    {  "Authorization" => "Bearer #{token_new}"  }
  end


  describe "POST api/v1/users#create" do
    subject { post api_v1_users_path( params: user_params, format: :json) }

    context 'correct params are passed' do
      it "has some additional info about user" do
        subject
        expect(JSON.parse(response.body)).to include_json(
          "email": "anon@anon.com",
          "full_name": "Anonimus Nope",
          "receive_emails": false
        )
      end
      it "returns created successfuly" do
        subject
        expect(response).to have_http_status(201)
      end
      it "returns correct partial" do
        subject
        expect(response).to render_template(partial: '_user')
      end
      it 'adds new object to db' do
        expect{subject}.to change(User, :count).by(1)
      end
      it "has header with new token" do 
        subject
        expect(response.header["Authorization: Bearer"]).to be_present
      end
    end

    context "incorrect params are passed" do
      let(:user_params) do
        {
          "email": "anon@anon.com",
          "password": "",
          "first_name": "Anonimus",
          "last_name": "Nope"
         }
      end
      it "returns error Unprocessable Entity" do
        subject
        expect(response).to have_http_status(422)
      end
      it "hasn\'t token inside header" do 
        subject
        expect(response.header["Authorization: Bearer"]).to_not be_present
      end
      it "hasn\'t token inside body" do 
        subject
        expect(response.body["Authorization: Bearer"]).to_not be_present
      end
      it 'doesn\'t create new object' do
        expect{subject}.to change(User, :count).by(0)  
      end
      it "returns correct error message" do
        subject
        expect(JSON.parse(response.body)['errors']).to eq(["Password can\'t be blank"])
      end
    end
  end

  describe "GET api/v1/user#show" do
    context "correct params are passed" do
      subject { get api_v1_user_path( format: :json), headers: token  }
      
      it "has some additional info about user" do
        subject
        p response.body
        expect(JSON.parse(response.body)).to include_json(
          "id": user.id,
          "email": user.email,
          "full_name": user.full_name,
          "receive_emails": user.receive_emails
        )
      end
      it "returns correct status" do
        subject
        expect(response).to have_http_status(200)
      end
      it "returns correct partial" do
        subject
        expect(response).to render_template(partial: '_user')
      end
    end

    context "incorrect params are passed" do 
      subject { get api_v1_user_path( format: :json), headers: {:Authorization => "Token 123"} }
      it "returns error Unauthorized" do
        subject
        expect(response).to have_http_status(401)
      end
      it "returns correct error message" do
        subject
        expect(JSON.parse(response.body)['message']).to eq("Please Login")
      end
    end
  end

  describe "GET api/v1/users#index" do
    context "correct params are passed" do
      let!(:user2) { create(:user) }
      subject { get api_v1_users_path( format: :json), headers: token  }
      it "return json wirth 2 users" do
        subject
        expect(JSON.parse(response.body)).to include_json([
          {   
            "id": user2.id,
            "email": user2.email,
            "full_name": user2.full_name,
            "receive_emails": user2.receive_emails
          },{
            "id": user.id,
            "email": user.email,
            "full_name": user.full_name,
            "receive_emails": user.receive_emails
            } ] )
      end
      it "returns status ok" do
        subject
        expect(response).to have_http_status(200)
      end
      it "returns correct partial" do
        subject
        expect(response).to render_template(:index)
      end
    end

    context "iccorrect params are passed" do 
      subject { get api_v1_users_path( format: :json), headers: {:Authorization => "Token 123"} }
      it "returns error Unauthorized" do
        subject
        expect(response).to have_http_status(401)
      end
      it "returns correct error message" do
        subject
        expect(JSON.parse(response.body)['message']).to eq("Please Login")
      end
    end
  end
end
