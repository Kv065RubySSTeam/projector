require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let!(:user) { create :user }

  context 'when user is logged in' do
    before { sign_in user }

    it { expect(user).to be_present }

    describe '#index' do
      let(:user1) { create(:user, email: 'Prudence.Gottlieb@gmail.com') }
      let(:user2) { create(:user, email: 'Israel96@gmail.com') }
      let(:user3) { create(:user, email: 'Marcelo_Kiehn@hotmail.com') }
      let(:user4) { create(:user, email: 'Milford91@yahoo.com') }
      let(:user5) { create(:user, email: 'Filomena.Reichel53@yahoo.com') }

      before do
        sign_in user1
        sign_in user2
        sign_in user3
        sign_in user4
        sign_in user5
      end

      subject { get users_path(params: params, format: :json) }

      context 'when get users json' do
        let(:params) do
          { search: '' }
        end

        it 'has return status success' do
          is_expected.to eq(200)
        end

        it 'has return all users length' do
          subject
          expect(JSON.parse(response.body).length).to eq(User.count)
        end
      end

      context 'when search certain user' do
        let(:params) do
          { search: 'M' }
        end

        it 'has return status success' do
          is_expected.to eq(200)
        end

        it 'has return correct user length' do
          subject

          json_users_with_searched_email = JSON.parse(response.body).select do |user|
            user['email'].start_with?(params[:search])
          end

          db_users_with_searched_email = User.all.select do |user|
            user['email'].start_with?(params[:search])
          end

          expect(json_users_with_searched_email.length).to eq(db_users_with_searched_email.length)
        end
      end
    end

    describe '#show' do
      subject { get user_path, params: { id: user.id } }

      it { is_expected.to render_template('users/show') }
    end
  end

  # Devise session
  describe '#new' do
    context 'when get signup request' do
      subject { get new_user_registration_path }

      it { is_expected.to render_template('devise/registrations/new') }
    end
  end
end
