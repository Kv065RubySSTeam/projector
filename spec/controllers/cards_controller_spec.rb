require 'rails_helper'
require_relative '../support/devise'

RSpec.describe CardsController, type: :controller do

  let(:current_user) { create(:user) }

  before do
    sign_in current_user
  end

  shared_examples "an unprocessible entity response" do 
    before(:each) { subject } 
    it "returns flashes errors" do
      expect(flash[:error]).to include(flash_message)
    end
    
    it "returns unprocessible entity response" do
      expect(response.status).to eq(422)
    end
  end

  let!(:user) { controller.current_user }
  let!(:membership) { create(:membership, user: user, board: board) }
  let!(:card) { create(:card) }
  let!(:column) { card.column }
  let!(:board) { column.board }
  let(:card_params) { { board_id: board, column_id: column, id: card } }

  describe '#new' do
    subject do
      get :new, xhr: true, format: :js, params: card_params
    end

    before(:each) { subject }
    context 'correct params are passed' do
      it 'shows card form' do
        expect(response.status).to eq(200)
      end
      it "returns successful response and renders new" do
        expect(response.status).to render_template(:new)
      end
    end
  end

  describe '#create' do
    let(:position) { column.last_card_position }
    let(:title) { 'title' }
    let(:body) { '<div></div>' }
    let(:params) { { title: title, body: body, position: position + 1, user_id: user.id } }
    subject do
      post :create, format: :js, params: { column_id: column, board_id: board, card: params }
    end    
    context 'with valid params' do
      it 'creates a new card' do
        expect { subject }.to change(Card, :count).by(1)
      end
      it 'returns created card' do
        subject
        expect(assigns(:card)).to eql(Card.last)
      end
      it 'returns 200 response status' do
        subject
        expect(response.status).to eq(200)
      end
    end
    context 'with invalid title' do
      let(:flash_message) { 'Title is too short' }
      let(:title) { '' } 
      it_behaves_like "an unprocessible entity response"
    end
  end

  describe '#destroy' do
    subject do
      delete :destroy, format: :js, params: card_params
    end

    context 'destroy card request' do
      it 'checks if card was deleted' do
        subject
        expect(Card.discarded).to include(card)
      end
      it 'shows successful flashes' do
        subject
        expect(flash[:success]).to include('Card was successfully deleted!')
      end
      it 'deletes the card' do
        subject
        expect(Card.kept).not_to include(card)
      end

      context 'destroy card with valid params' do
        it 'returns 200 response status' do
          subject
          expect(response.status).to eq(200)
        end
      end
    end
  end

  describe '#edit' do
    subject do
      get :edit, xhr: true, params: card_params
    end
    context 'with valid params' do 
      it 'renders edit template inside sidebar' do
        expect(subject).to render_template(:edit)
      end
      it 'returns 200 response status' do
        expect(response.status).to eq(200)
      end
    end
  end

  describe '#update' do
    subject do
      patch :update, format: :js, params: params
    end

    context 'correct params are passed' do
      let(:params) do
        { board_id: board, column_id: column, id: card, card: { title: 'title'} }
      end

      it 'is successfully created' do
        subject
        expect(flash[:success]).to include('Card was successfully updated.')
        expect(response.status).to eq(200)
      end

      it 'fields were successfully updated' do
        card_title_before = card.title
        card_body_before = card.body
        subject
        expect(card.reload.title).not_to eql(card_title_before)
        expect(card.reload.body).not_to eql(card_body_before)
      end
    end

    context 'invalid params are passed' do
      let(:params) do
        { board_id: board, column_id: column, id: card, card: { title: 'title', body: '' } }
      end
      it 'returns bad params response' do
        subject
        expect(controller).to set_flash
      end
    end
  end

  describe 'check update_position ' do
    let!(:source_col) { create(:column_with_cards, board: board) }
    let!(:target_col) { create(:column_with_cards, board: board) }

    subject do
      put :update_position, format: :js, params: {
        board_id: board.id,
        column_id: target_col.id,
        id: moved_id,
        source_cards_id: source_cards_ids,
        target_cards_id: target_cards_ids
      }
    end
    context 'card moves from one column to another' do
      let(:source_cards_ids) { source_col.cards.ids[0...-1].to_s }
      let(:moved_id) { source_col.cards.ids.pop }
      let(:target_cards_ids) { target_col.cards.ids.unshift(moved_id).to_s }
      it 'returns 200 response status' do
        subject
        expect(response.status).to eq(200)
      end
      it 'updates card position is updated and correct' do
        expect(source_col.cards.ids).to_not match_array(eval(source_cards_ids))
        expect(target_col.cards.ids).to_not match_array(eval(target_cards_ids))
        subject
        expect(source_col.reload.cards.ids).to match_array(eval(source_cards_ids))
        expect(target_col.reload.cards.ids).to match_array(eval(target_cards_ids))
      end
    end
    context 'passed params of user coordinates are the same' do
      let(:source_cards_ids) { source_col.cards.ids.to_s }
      let(:moved_id) { source_col.cards.last.id }
      let(:target_cards_ids) { target_col.cards.ids.to_s }
      it 'does not move position' do
        subject
        expect(source_col.cards).to match_array(source_col.reload.cards)
        expect(response.status).to eq(200)
      end
    end

    context 'the last card moves at the same column to the first positionn' do
      let!(:source_cards_ids) { nil }
      let!(:cards_in_column) { target_col.cards.ids }
      let(:moved_id) { target_col.cards.ids.pop }
      let(:target_cards_ids) { target_col.cards.ids[0...-1].unshift(moved_id).to_s }
      it 'returns moved card on the first place position' do
        subject
        expect(target_col.cards.find_by(position: '1').id).to eq(cards_in_column.last)
        expect(response.status).to eq(200)
      end
    end
  end

  describe '#add_assignee' do
    subject do 
      post :add_assignee, format: :js, params: params
    end
    let(:params) do
      { board_id: board.id, column_id: column.id, id: card.id, email: user.email }
    end
    context 'good params are passed' do
      it 'returns 200 response status' do
        subject
        expect(response.status).to eq(200)
      end
      it 'user is assigned to the card' do
        subject
        expect(card.reload.assignee_id).to eql(user.id)
      end
    end

    context 'invalid params are passed' do
      let(:params) do
        { board_id: board.id, column_id: column.id, id: card.id, email: "" }
      end
      it 'returns 404 response status' do
        subject
        expect(response.status).to eq(404)
      end
    end

    context 'invalid params are passed' do
      before do
        allow_any_instance_of(Card).to receive(:save).and_return(false)
      end
      it 'returns 422 response status' do
        subject
        expect(response.status).to eq(422)
      end
    end

  end

  describe '#remove_assignee' do
    subject do
      delete :remove_assignee, format: :js, params: card_params
    end
    context 'correct params are passed' do
      before do
        card.assignee_id = user.id
      end
      it 'returns 200 response status' do
        subject
        expect(response.status).to eq(200)
      end
      it 'checks if assignee is deleted' do
        subject
        expect(card.reload.assignee_id).to be_nil
      end
    end

    describe '#index' do
      subject do
        get :index
      end
      context 'check index method' do
        let(:board_user) { controller.current_user }
        let!(:board_with_cards) { create(:board_with_cards) }
        let!(:user_board_with_cards) { create(:board_with_cards, user: board_user) }
        let!(:membership) {create(:membership, user: board_user, board: user_board_with_cards) }
        let!(:columns) { user_board_with_cards.columns }
        let!(:cards) { Card.where(column_id: user_board_with_cards.columns.ids) }
        let!(:sorted_cards) { cards.order("title asc") }
        let!(:unavailable_cards) { create(:column_with_cards).cards }

        it 'has to return correct status 200' do
          expect(response.status).to eq(200)
        end
        it 'has return cards available for user' do
          expect(Card.available_for(board_user)).to match_array(cards)
        end
        it 'has not return cards unavailable for user' do
          expect(Card.available_for(board_user)).not_to match_array(unavailable_cards)
        end
      end
    end
  end
end
