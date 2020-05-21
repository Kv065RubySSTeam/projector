require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let!(:user) { build_stubbed :user }

  before(:each) do
    allow(view).to receive(:current_user).and_return(user)
  end

  before { render }

  describe 'main page elements' do
    it { expect(response).to have_tag('.card-content') }
    it { expect(response).to have_tag('.card-body') }
    it { expect(response).to have_tag('.card-title') }
    it { expect(response).to have_tag('img.rounded') }
    it { expect(response).to have_tag('.btn-group') }
  end

  describe 'button group' do
    it 'has back button' do
      expect(response).to have_tag('.btn', text: /Back/)
    end

    it 'has edit button' do
      expect(response).to have_tag('.btn', text: /Edit/)
    end

    it 'has delete button' do
      expect(response).to have_tag('.btn', text: /Delete account/)
    end
  end

  describe 'button actions' do
    it 'has edit link' do
      expect(response).to match('href="/users/edit"')
    end

    it 'has delete link' do
      expect(response).to match('href="/users"')
    end
  end

  describe 'user fields' do
    context 'with first and last name' do
      it { expect(response).to match(user.first_name) }
      it { expect(response).to match(user.last_name) }
    end

    it 'has user avatar' do
      expect(response).to match('/images/placeholder.jpg')
    end
  end
end
