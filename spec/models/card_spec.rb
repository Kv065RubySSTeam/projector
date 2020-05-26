require 'rails_helper'
require 'faker'

RSpec.describe Card, type: :model do

  let!(:card) { create :card, :with_tags }
  let!(:board_first) { create(:board_with_columns_cards) }
  let!(:board_second) { create(:board_with_columns_cards) }

  it 'check card to be valid after creation' do
    expect(card).to be_valid
  end

  describe 'assocations' do
    it { is_expected.to belong_to(:column).without_validating_presence }
    it { is_expected.to belong_to(:user).without_validating_presence }
    it { is_expected.to belong_to(:assignee).class_name('User').with_foreign_key(:assignee_id).without_validating_presence }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:taggings) }
    it { is_expected.to have_many(:tags).through(:tag_taggings) }
  end

  describe 'describe title length validation' do
    context "describe title length validation" do
      it "describe title length validation" do 
        expect(card).to validate_length_of(:title).is_at_least(2).is_at_most(50)
      end
    end
  end

  describe '#tag_list' do
    let(:card) { create(:card, tag_list: tags) }
    let(:tags) { ["jogging", "diving", "swimming"] }
    it { is_expected.to have_many(:tags).through(:tag_taggings) }

    context "card with tags" do
      it 'returns card with appropriate tags' do
        expect(card.tag_list).to match_array(tags)
      end
    end

    context "remove tag from taglist" do
      it 'removes tag from card taglist' do
        card.tag_list.remove('jogging')
        card.save
        expect(card.reload.tag_list).not_to include('jogging')
      end
    end

    context "add tag to taglist" do
      it 'adds tag to card taglist' do
        card.tag_list.add('running')
        card.save
        expect(card.reload.tag_list).to include('running')
      end
    end
  end

  describe '#available_for' do
    let!(:column) { create(:column_with_cards ) }
    let!(:board) { column.board }
    let!(:user) { board.user }
    let!(:membership) { create(:membership, user: user, board: board) }
    context "cards to be available for user" do
      it 'receives expected cards, which are available for user' do 
        expect(Card.available_for(user).kept).to match_array(column.cards) 
      end
    end
    context "cards to be unavailable for user" do
      let(:other_card) { create(:card) }
      it 'receives cards, which are unavailable for user' do 
        expect(Card.available_for(user)).not_to include(other_card) 
      end
    end
  end

  describe '#search' do
    shared_examples "an appropriate cards return" do
      it "expect correct card to be found" do 
        expect(subject).to include(card)
        expect(subject).not_to include(another_card) 
      end
    end

    subject { Card.search(input) }
    let!(:user) { build(:user, first_name: 'Ivan', last_name: 'Shi') }
    let!(:card) { create(:card, title: 'Lifo', body: 'Russel', user: user) }
    let!(:another_card) { create(:card, title: 'title', body: '<div>body</div>') }

    context 'pass card title - "Lifo" into input' do
      let(:input) { 'Lifo' }
      it_behaves_like "an appropriate cards return"
    end

    context 'pass first_name - "Ivan" into input' do
      let(:input) { 'Ivan' }
      it_behaves_like "an appropriate cards return"
    end

    context 'pass last_name - "Shi" into input' do
      let(:input) { 'Shi' }
      it_behaves_like "an appropriate cards return"
    end
  end

  describe '.position' do
    context 'column has no cards yet' do
      let!(:column) { create(:column ) }
      let!(:card) { create(:card) }
      it 'has no cards' do
        expect(card.position).to eq(1)
      end

      let(:cards) {create_list(:card, 6, column_id: column.id)}
      it 'cards already present' do
        expect(cards.last.position).to eq(cards.count)
      end
    end
  end

  describe '#assign' do
    let(:user) { create(:user) }
    subject { card.assign!(user) }
    before(:each) { subject }
    context 'assign correct user' do
      it 'expect user to be correct' do
        expect(card.assignee).to eq(user)
      end
    end

    context 'pass second user' do
      let!(:user_second) { create(:user) }
      it 'expect to add correct assignee to card' do
        expect(card.assignee).not_to eq(user_second)
      end
    end

    context 'remove assignee from card' do
      it 'expect assignee to be removed from card' do
        card.remove_assign!
        expect(card.assignee).to be_nil
      end
    end
  end

  describe 'filter_cards' do
    let!(:user) { board_first.user }
    let!(:membership) { create(:membership, user: user, board: board_first) }
    let!(:first_board_card) { board_first.columns.first.cards.first }
    let!(:second_board_card) { board_second.columns.first.cards.first }
    before do 
      board_first.columns.first.cards.each do |card|
        card.assign!(user)
        card.save 
        card.discard
      end
    end
    context "filter returns correct cards - assigned and available for user" do
      it 'expect to return correct cards, where assignee is user' do 
        expect(Card.available_for(user).assigned(user)).to include(first_board_card) 
      end
      it 'expect not to innclude cards, not assigned to user' do 
        expect(Card.available_for(user).assigned(user)).not_to include(second_board_card) 
      end
    end
    context "discarded cards" do
      it 'expect to return discarded cards' do 
        expect(board_first.columns.first.cards.first.discarded_at).not_to be_nil
        expect(Card.filter('deleted', user)).to include(first_board_card)
      end
      it 'expect not to contain existing cards' do 
        expect(card.discarded_at).to be_nil
        expect(Card.filter('deleted', user)).not_to include(card)
      end
    end
    context "all cards" do
      it 'expect to return all cards' do 
        expect(Card.filter('all', user)).to include(first_board_card)
        expect(Card.filter('all', user)).to include(card)
      end
    end
    context "cards to be filtered by board" do
      it 'does not receive cards from another board' do 
        expect(Card.available_for(user).filter_by_board(board_first.title)).not_to include(second_board_card) 
      end
      it 'receives cards from exact board' do 
        expect(Card.available_for(user).filter_by_board(board_first.title)).to include(first_board_card) 
      end
    end
  end
end
