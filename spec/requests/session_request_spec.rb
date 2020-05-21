require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let(:user) { build_stubbed :user }

  before do
    sign_in user
  end

  describe 'current_user' do
    before { get root_path }
    it { expect(controller.current_user).to eq user }
  end

  describe 'sign in and sign out' do
    context 'when user sign in' do
      it do
        get root_path
        expect(response).to render_template(:index)
      end

      it 'has confirmed user' do
        user.confirmed_at = nil
        get root_path
        expect(response).to render_template(:index)
      end
    end

    context 'when user sign out' do
      it do
        sign_out user
        get root_path
        expect(response).not_to render_template(:index)
      end
    end

    context 'when user is not confirmed' do
      it do
        user.confirmed_at = nil
        get root_path
        expect(response).to render_template(:index)
      end
    end
  end
end
