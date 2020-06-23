# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::PasswordControllers', type: :request do
  let!(:user) do
    create(:user,
           password: 'password',
           password_confirmation: 'password',
           reset_password_token: SecureRandom.uuid,
           reset_password_sent_at: Time.now)
  end

  describe 'POST api/v1/password#new' do
    let(:valid_attributes) do
      attributes_for(:user, email: user.email)
    end

    context 'correct params are passed' do
      subject { post api_v1_users_password_new_path(params: valid_attributes, format: :json) }
      it 'returns status 200' do
        subject
        expect(response).to have_http_status(200)
      end
      it 'should return correct message' do
        subject
        expect(JSON.parse(response.body)['success']).to eq('Successfully sended email.')
      end
    end

    context 'incorrect params are passed' do
      let(:invalid_email) do
        attributes_for(:user, email: 'invalid@gmail.com')
      end
      subject { post api_v1_users_password_new_path(params: invalid_email, format: :json) }
      it 'returns created status 404' do
        subject
        expect(response).to have_http_status(404)
      end
      it 'should return correct message when user could\'t find' do
        subject
         expect(JSON.parse(response.body)['error']).to eq("Couldn't find User")
      end
    end
  end

  describe 'PUT api/v1/password#edit' do
    let!(:reset_password_params) do
      {
        reset_password_token: user.reset_password_token,
        new_password: 'new_password',
        new_password_confirmation: 'new_password'
      }
    end
    subject { put api_v1_users_password_edit_path(format: :json, params: reset_password_params) }
    context 'correct params are passed' do
      it 'return status new password created' do
        subject
        expect(response).to have_http_status(201)
      end
      it 'returns correct partial' do
        subject
        expect(response).to render_template(partial: '_user')
      end
      it 'has header with new token' do
        subject
        expect(response.header['Authorization: Bearer']).to be_present
      end
    end

    context 'incorrect params are passed' do
      let!(:reset_password_params) do
        {
          reset_password_token: user.reset_password_token,
          new_password: 'new_password',
          new_password_confirmation: 'incorrect'
        }
      end
      it 'returns status 422' do
        subject
        expect(response).to have_http_status(422)
      end
      it 'should return correct message' do
        subject
         expect(JSON.parse(response.body)['error']).to eq("Password confirmation doesn't match Password.")
      end
    end
  end
end
