require 'rails_helper'
require 'cancan/matchers'

RSpec.describe "Api::V1::Cards", type: :request do
  let!(:current_user) { create(:user) }
  let!(:card) { create(:card) }
  let!(:column) { card.column }
  let!(:board) { column.board }
  let!(:membership) { create(:membership, user: current_user, board: board) }
  let(:card_params) { { board_id: board, column_id: column, card_id: card } }

  let(:token_new) { Users::CreateTokenService.call(current_user) }
  let(:token) do
    {  "Authorization" => "Bearer #{token_new}"  }
  end

  shared_examples 'not authorized error' do
    before do
      subject
    end

    it 'returns json with with not authorized error' do
      expect(JSON.parse(response.body)['error']).to eq(
        'You are not authorized to access this page.'
      )
    end

    it 'returns 401 error' do
      expect(response.status).to eq(401)
    end
  end

  describe "#index" do
    subject { get api_v1_cards_path(page: page, format: :json), xhr: true }
    let(:page) { 1 }

    context "available cards" do
      it "returns available cards" do
        subject
        expect(JSON.parse(response.body).count).to match(
          Card.available_for(current_user).count
        )
      end
    end
  end

  describe "#create" do
    subject { post api_v1_board_column_cards_path(board, column, card: card_params, format: :json), xhr: true, headers: token }
    let(:card_params) do
      { "title": "Title", "body": "<div>body</div>", "user_id": current_user.id }
    end

    context "correct params are passed" do
      it "has success status" do
        subject
        expect(response.status).to eq 201
      end
      it "renders correct template" do
        subject
        expect(subject).to render_template(:show)
      end
    end

    context "invalid params are passed" do
      let(:card_params) {  { title: '' } }
      before(:each) { subject }
      let(:errors) do
        ['Title is too short (minimum is 2 characters)']
      end
      it "returns unprocessible entity response" do
        subject
        expect(response.status).to eq 422
      end
      it 'returns error' do
        expect(assigns(:card).errors.to_a).to match_array(errors)
      end
    end

    context "card was created" do
      it "adds new record" do
        expect{ subject }.to change{ Card.count }.by(1)
      end

      it "has correct user" do
        subject
        expect(Card.last.user).to eq current_user 
      end
      it "has correct title" do
        subject
        expect(Card.last.title).to eq card_params[:title] 
      end
    end
  end

  describe "#show" do
    subject { get api_v1_board_column_card_path(board, column, card, format: :json), xhr: true, headers: token }

    context "correct params are passed" do
      it "has success status" do
        subject
        expect(response.status).to eq 200
      end
      it "renders correct template" do
        subject
        expect(subject).to render_template(:show)
      end
    end
  end

  describe "#update" do
    subject { put api_v1_board_column_card_path(board, column, card, card: card_params, format: :json), xhr: true, headers: token }
    let(:title) { "696" }
    let(:card_params) do
      { "title": title }
    end
    context "correct params are passed" do
      it "has success status" do
        subject
        expect(response.status).to eq 200
      end
      it "renders correct template" do
        subject
        expect(subject).to render_template(:show)
      end

      it "returns json with correct title" do
        subject
        expect(JSON.parse(response.body)).to include_json(
          title: title
        )
      end
    end

    context 'invalid update params' do
      let(:card_params) {  { title: '' } }
      before(:each) { subject }
      let(:errors) do
        ['Title is too short (minimum is 2 characters)']
      end

      it "doesn't update card" do
        board.reload
        expect(card.title).to_not eq(card_params[:title])
      end

      it 'returns error' do
        expect(assigns(:card).errors.to_a).to match_array(errors)
      end

      it "returns unprocessible entity response" do
        expect(response.status).to eq(422)
      end
    end 
  end

  describe "#remove_assignee" do
    subject { delete remove_assignee_api_v1_board_column_card_path(board, column, card, format: :json), xhr: true, headers: token}
    let!(:membership) { create(:membership, user: current_user, board: board) }
    let!(:assignee) { create(:card, assignee: current_user) }

    context "correct params are passed" do
      it "has success status" do
        subject
        expect(response.status).to eq 200
      end
      it "returns the correct message" do
        subject
        expect(JSON.parse(response.body)).to include_json(
          message: "Assignee was successfully deleted!"
        )
      end
    end
  end

  describe "#add_assignee" do
    subject { post add_assignee_api_v1_board_column_card_path(board, column, card, card: card_params, format: :json), xhr: true, headers: token }
    let!(:membership) { create(:membership, user: current_user, board: board) }
    let!(:assignee) { create(:card, assignee: nil) }
    let(:card_params) do
      { "email": "#{current_user.email}" }
    end

    context "correct params are passed" do
      it "has success status" do
        subject
        expect(response.status).to eq 404
      end
    end
  end

  describe "#destroy" do
    subject { delete api_v1_board_column_card_path(board, column, card, format: :json), xhr: true, headers: token }

    context "successful request" do
      it "has success status" do
        subject
        expect(response.status).to eq(200)
      end

      it "returns success json" do
        subject
        expect(JSON.parse(response.body)).to include_json(
          message: "Card was successfully destroyed!"
        )
      end
    end

    context "card deleted" do
      it "deletes record" do
        expect(Card.kept).not_to include(:card)
      end
    end
  end
end
