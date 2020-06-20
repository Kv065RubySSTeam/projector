require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { create :user }

  describe 'associations' do
    context 'has_many' do
      it { should have_many(:columns).dependent(:destroy) }
      it { should have_many(:cards).dependent(:destroy) }
      it { should have_many(:comments).dependent(:destroy) }
      it { should have_many(:assigned_cards).class_name('Card') }
      it { should have_many(:memberships).dependent(:destroy) }
      it { should have_many(:boards).through(:memberships) }
    end

    context 'has_one_attached' do
      it { should respond_to(:avatar) }
    end
  end

  describe 'database table' do
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:encrypted_password).of_type(:string) }
    it { is_expected.to have_db_column(:reset_password_token).of_type(:string) }

    it { is_expected.to have_db_column(:reset_password_sent_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:remember_created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }

    it { is_expected.to have_db_column(:confirmation_token).of_type(:string) }
    it { is_expected.to have_db_column(:confirmed_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:confirmation_sent_at).of_type(:datetime) }

    it { is_expected.to have_db_column(:unconfirmed_email).of_type(:string) }
    it { is_expected.to have_db_column(:first_name).of_type(:string) }

    it { is_expected.to have_db_column(:first_name).of_type(:string) }
    it { is_expected.to have_db_column(:last_name).of_type(:string) }
    it { is_expected.to have_db_column(:provider).of_type(:string) }
    it { is_expected.to have_db_column(:uid).of_type(:string) }
  end

  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_presence_of :password }
    it { should validate_confirmation_of :password }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'attributes' do
    context 'with valid params' do
      it { expect(user).to be_valid }
    end
  end

  describe 'email' do
    subject { user }

    context 'with valid address' do
      it { is_expected.to be_valid }
    end

    context 'with invalid address' do
      before { user.email = 'invalid_example' }

      it { is_expected.to_not be_valid }
    end

    context 'with empty address' do
      before { user.email = nil }

      it { is_expected.to_not be_valid }
    end
  end

  describe 'first and last name' do
    subject { user }

    context 'when empty' do
      before do
        user.first_name = nil
        user.last_name = nil
      end

      it { is_expected.to_not be_valid }
    end

    context 'when too long' do
      before { user.first_name = 'Name' * 100 }

      it { is_expected.to_not be_valid }
    end
  end

  describe 'password' do
    subject { user.valid_password?(user.password) }

    context 'when is correct' do
      it { is_expected.to be_truthy }
    end

    context 'when is empty' do
      before { user.password = '' }

      it { is_expected.to be_falsey }
    end

    context 'when is incorrect' do
      it { expect(user.valid_password?(user.encrypted_password.upcase)).to be_falsey }
    end
  end

  describe 'avatar' do
    subject { user.avatar }

    it { is_expected.to be_blank }
    it { is_expected.not_to be_present }
  end

  describe '#full_name' do
    subject { "#{user.first_name} #{user.last_name}" }

    context 'with valid first and last name' do
      it { is_expected.to eq user.full_name }
    end
  end

  # Scopes
  describe 'model scope' do
    context 'with valid search params' do
      subject { users }
      let(:users) { User.search(user) }

      it { is_expected.to contain_exactly(*User.search(user: user).to_a) }
    end

    context 'with administrated boards' do
      it { should have_many(:administrated_boards).conditions(memberships: { admin: true }).class_name('Board') }
    end
  end
end
