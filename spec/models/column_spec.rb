require 'rails_helper'

RSpec.describe Column, type: :model do
  it 'has a valid factory' do
    expect(build(:column)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:board) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:cards).dependent(:destroy) }
  end

  describe 'indexes' do
    it { is_expected.to have_db_index(:user_id) }
    it { is_expected.to have_db_index(:board_id) }
  end

  describe 'validations' do
    context 'name' do
      it { is_expected.to have_db_column(:name).of_type(:string) }
      it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(50) }
    end

    context "position" do
      let(:board) { create(:board) }
      let(:column) { create(:column) }
      let(:columns_list) { create_list(:column, 5, board: board) }

      it { is_expected.to have_db_column(:position).of_type(:integer) }

      it 'column position uniqueness in board' do
        expect(columns_list.map(&:position).uniq.length).to eq(columns_list.length)
      end
    end
  end

  describe "#last_card_position" do 
    let(:column_without_cards) { create(:column) }
    let(:column_with_cards) { create(:column_with_cards) }

    context 'with no cards' do
      subject { column_without_cards.last_card_position }
      
      it { is_expected.to be_nil }
    end

    context 'with cards' do
      subject {column_with_cards.last_card_position}
      
      it { is_expected.to eq(column_with_cards.cards.count) }
    end
  end
end
