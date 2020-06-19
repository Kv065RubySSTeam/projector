require 'rails_helper'
require 'cancan/matchers'

RSpec.describe "Api::V1::Comments", type: :request do
  let!(:membership) { create(:membership) }
  let!(:board) { membership.board }
  let!(:user) { membership.user }
  let!(:column) { create(:column, board: board, user: user) }
  let!(:card) { create(:card, column: column, user: user) }
  
  before do
    sign_in user
  end

  shared_examples "a not authorized error" do
    let!(:user2) { create(:user)}

    before do
      sign_out user
      sign_in user2
      subject
    end

    it "returns json with with not authorized error" do
      expect(JSON.parse(response.body)).to include_json(
        error: "You are not authorized to access this page."
      )
    end

    it "returns 401 error" do
      expect(response.status).to eq(401)
    end
  end

  describe "#index" do
    subject { get api_v1_board_column_card_comments_path(board, column, card, page: page, format: :json) }
    let(:page) { 1 }

    context "successful request" do
      it "returns successful status" do
        subject
        expect(response.status).to eq(200)
      end

      it "render index template" do
        subject
        expect(response.status).to render_template(:index)
      end
    end

    context "without comments" do
      it "returns no comments" do
        subject
        expect(assigns(:comments)).to be_empty
        expect(JSON.parse(response.body)).to be_empty
      end
    end

    context "with 5 comments" do
      let!(:card_comments) { create_list(:comment, 5, user: user, card: card) }
      let!(:random_comments) { create_list(:comment, 5) }
      
      it "returns 5 comments" do
        subject
        expect(assigns(:comments)).to match_array(card_comments)
        expect(assigns(:comments)).to_not contain_exactly(random_comments)
        expect(JSON.parse(response.body).size).to eq(5)
      end
    end
    
    context "with pagination" do
      let!(:page) { 2 }
      let!(:all_comments) {create_list(:comment, 7, card: card, user: user)}
      let!(:expected_comments) { Comment.order(created_at: :asc).limit(2) }   
      
      it 'does paginate records' do
        subject
        expect(assigns(:comments)).to match_array(expected_comments)
        expect(JSON.parse(response.body).size).to eq(2)
      end
    end

  end

  describe "#show" do
    subject { get api_v1_board_column_card_comment_path(board, column, card, comment, format: :json), xhr: true  }
    let!(:comment) { create(:comment, card: card, user: user) }

    context 'without permission' do
      it_behaves_like "a not authorized error"
    end

    context "successful request" do
      it "returns successful status" do
        subject
        expect(response.status).to eq(200)
      end

      it "render show template" do
        subject
        expect(response.status).to render_template(:show)
      end

      it "returns json with corrent user and body" do
        subject
        expect(JSON.parse(response.body)).to include_json(
          body: comment.body,
          author: user.full_name
        )
      end

    end
  end

  describe "#create" do
    subject { post api_v1_board_column_card_comments_path(board, column, card, comment: comment_params, format: :json) }
    let(:comment_params) do
      { 
        "body": "Test",
        "user_id": user.id
      }
    end

    context "correct params are passed" do
      it "has success status" do
        subject
        expect(response.status).to eq 201
      end
    end
    
    context "comment was created" do
      it "adds new record" do
        expect{ subject }.to change{ Comment.count }.by(1)
      end

      it "has correct user and body" do
        subject
        expect(Comment.last.user).to eq user 
        expect(Comment.last.body).to eq comment_params[:body] 
      end
    end
  
    context "invalid params are passed" do
      let(:comment_params) do
        { body: "" }
      end
  
      it "has unprocessable entity status" do
        subject
        expect(response.status).to eq 422
      end
  
      it "adds returns json with errors" do
        subject
        expect(JSON.parse(response.body)).to include_json(
            errors: ["User must exist", 
                    "Body can't be blank"]
        )
      end

      it "not adds new comment" do
        expect{ subject }.to change(Comment, :count).by(0)  
      end
    end
  end

  describe "#update" do
    subject { put api_v1_board_column_card_comment_path(board, column, card, comment, comment: comment_params, format: :json) }
    let!(:comment) { create(:comment, card: card, user: user) }
    
    context 'without permission' do
      let(:comment_params) do
        { body: "Test" }
      end
      it_behaves_like "a not authorized error"
    end

    context "correct params are passed" do
      let(:comment_params) do
        { body: "Test" }
      end

      it "has success status" do
        subject
        expect(response.status).to eq 200
      end

      it "comment body was updated" do
        subject
        expect(JSON.parse(response.body)).to include_json(
          body: "Test",
          author: user.full_name
        )
      end
    end

    context "invalid body are passed" do
      let(:comment_params) do
        { body: "" }
      end

      it "has unprocessable entity status" do
        subject
        expect(response.status).to eq 422
      end

      it "adds returns json with errors" do
        subject
        expect(JSON.parse(response.body)).to include_json(
            errors: [ "Body can't be blank" ]
        )
      end
    end

  end

  describe "#destroy" do
    subject { delete api_v1_board_column_card_comment_path(board, column, card, comment, format: :json) }
    let!(:comment) { create(:comment, card: card, user: user) }
    
    context 'without permission' do
      it_behaves_like "a not authorized error"
    end

    context "successful request" do
      it "has success status" do
        subject
        expect(response.status).to eq(200)
      end

      it "returns success json" do
        subject
        expect(JSON.parse(response.body)).to include_json(
          message: "Comment successfully deleted."
        )
      end
    end

    context "comment deleted" do
      it "deletes record" do
        expect{ subject }.to change(Comment, :count).by(-1)
      end
    end

  end

end
