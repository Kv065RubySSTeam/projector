require 'rails_helper'
require 'pp'

RSpec.describe "Comments", type: :request do
  let!(:membership) { create(:membership) }
  let!(:board) { membership.board }
  let!(:user) { membership.user }
  let!(:column) { create(:column, board: board, user: user) }
  let!(:card) { create(:card, column: column, user: user) }
  let(:referer) { 'http://example.com/test' }

  before do
    sign_in user
  end

  shared_examples "not authorized error" do
    let(:user2) { create(:user) }

    before do
      sign_out user
      sign_in user2
      subject
    end

    it 'has redirect status' do 
      expect(response.status).to eq(302)
    end

    it 'has correct redirect location' do 
      expect(response.location).to eq(referer)
    end

    it 'sets correct flash' do 
      expect(controller).to set_flash[:error].to("You are not authorized to access this page.")
    end
  end

#Index  
  describe "#index" do
    subject { get board_column_card_comments_path(board, column, card, page: page, format: :js), xhr: true }
    let(:page) { 1 }

    context "not authorized user" do
      before do
        sign_out user
      end

      it "has status unauthorized" do
        subject
        expect(response.status).to eq(401)
        expect(response.body).to eq 'You need to sign in or sign up before continuing.'      
      end
    end

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
      end
    end

    context "with 5 comments" do
      let!(:card_comments) { create_list(:comment, 5, user: user, card: card) }
      let!(:random_comments) { create_list(:comment, 5) }
      
      it "returns 5 comments" do
        subject
        expect(assigns(:comments)).to match_array(card_comments)
        expect(assigns(:comments)).to_not contain_exactly(random_comments)
      end
    end
    
    context "with pagination" do
      let(:page) { 2 }
      let(:all_comments) {create_list(:comment, 7, card: card, user: user)}
      let(:expected_comments) { Comment.order(created_at: :asc).limit(2) }   
      
      it 'does paginate records' do
        subject
        expect(assigns(:comments)).to match_array(expected_comments)
      end
    end
  end

#Edit
  describe "#edit" do
    subject { get edit_board_column_card_comment_path(board, column, card, comment, format: :js), xhr: true }
    let!(:comment) { create(:comment, card: card, user: user) }

    context "successful request" do
      it "returns successful status" do
        subject
        expect(response.status).to eq(200)
      end

      it "render edit template" do
        subject
        expect(response.status).to render_template(:edit)
      end
    end
  end

#Create
  describe "#create" do
    subject { post board_column_card_comments_path(board, column, card, comment: comment_params, format: :js) }

    context "not authorized user" do
      let(:comment_params) do
        { body: "Test" }
      end

      before do
        sign_out user
      end

      it "has status unauthorized" do
        subject
        expect(response.status).to eq(401)
        expect(response.body).to eq 'You need to sign in or sign up before continuing.'
      end
    end

    context "correct params are passed" do
      let(:comment_params) do
        { body: "Test" }
      end
  
      it "has success status" do
        subject
        expect(response.status).to eq 200
      end
      
      it "adds success flash" do
        subject
        expect(flash[:success]).to eq "Comment was successfully created."
      end
    end
    
    context "comment was created" do
      let(:comment_params) do
        { body: "Test" }
      end
      
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
  
      it "adds error flash" do
        subject
        expect(flash[:error]).to eq "Body can't be blank"
      end

      it "not adds new comment" do
        expect{ subject }.to change(Comment, :count).by(0)  
      end
    end
  end

#Update  
  describe "#update" do
    subject { put board_column_card_comment_path(board, column, card, comment, comment: comment_params, format: :js), headers: { 'HTTP_REFERER': referer } }
    let!(:comment) { create(:comment, card: card, user: user) }
    
    context "not authorized user" do
      let(:comment_params) do
        { body: "Test" }
      end

      before do
        sign_out user
      end

      it "has status unauthorized" do
        subject
        expect(response.status).to eq(401)
        expect(response.body).to eq 'You need to sign in or sign up before continuing.'
      end
    end

    context "correct params are passed" do
      let(:comment_params) do
        { body: "Test" }
      end

      it "has success status" do
        subject
        expect(response.status).to eq 200
      end

      it "adds success flash" do
        subject
        expect(flash[:success]).to eq "Comment was successfully updated."
      end
    end

    context "comment body was updated" do
      let(:comment_params) do
        { body: "Test" }
      end

      it "changes record body value" do
        body_before = comment.body
        subject
        expect(comment.reload.body).not_to eq (body_before)
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

      it "adds error flash" do
        subject
        expect(flash[:error]).to eq "Body can't be blank"
      end
    end

    context 'without permission' do
      let(:comment_params) do
        { body: "test" }
      end

      it_behaves_like "not authorized error"
    end
 
  end

#Destroy 
  describe "#destroy" do
    subject { delete board_column_card_comment_path(board, column, card, comment, format: :js), headers: { 'HTTP_REFERER': referer } }
    let!(:comment) { create(:comment, card: card, user: user) }
    
    context "not authorized user" do
      before do
        sign_out user
      end

      it "has status unauthorized" do
        subject
        expect(response.status).to eq(401)
        expect(response.body).to eq 'You need to sign in or sign up before continuing.'
      end
    end

    context "successful request" do
      it "has success status" do
        subject
        expect(response.status).to eq 200
      end

      it "adds success flash" do
        subject
        expect(flash[:success]).to eq "Comment was successfully deleted."
      end
    end

    context "comment deleted" do
      it "deletes record" do
        expect{ subject }.to change(Comment, :count).by(-1)
      end
    end

    context 'without permission' do
      let(:comment_params) do
        { body: "test" }
      end

      it_behaves_like "not authorized error"
    end
  end
end
