require 'rails_helper'

RSpec.describe "Api::V1::Tags", type: :request do
  let!(:membership) { create(:membership) }
  let!(:board) { membership.board }
  let!(:user) { membership.user }
  let!(:column) { create(:column, board: board, user: user) }
  let!(:card) { create(:card, column: column, user: user) }
  
  let(:token_new) { Users::CreateTokenService.call(user) }
  let(:token) do
    {  "Authorization" => "Bearer #{token_new}"  }
  end

  shared_examples "a not authorized error" do
    let!(:user2) { create(:user) }

    it "returns json with with not authorized error" do
      expect(JSON.parse(response.body)).to include_json(
        message: "Please Login"
      )
    end

    it "returns 401 error" do
      expect(response.status).to eq(401)
    end
  end

  describe "#index" do
    subject { get api_v1_board_column_card_tags_path(board, column, card, format: :json), headers: token }

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
        expect(assigns(:tags)).to be_empty
        expect(JSON.parse(response.body)).to be_empty
      end
    end

    context "with tags" do
      before do 
        card.tag_list.add("awesome", "good")
        card.save
      end
      it "returns 2 tags" do
        subject
        expect(assigns(:tags)).to match_array(card.tags)
        expect(JSON.parse(response.body).size).to eq(2)
      end
    end

  end

  describe "#show" do
    subject { get api_v1_board_column_card_tag_path(board, column, card, tag, format: :json), xhr: true, headers: token  }

    before do
      card.tag_list.add("good")
      card.save
    end

    let(:tag) { card.tags.find_by(name: 'good') }

    context 'without permission' do
      subject { get api_v1_board_column_card_tag_path(board, column, card, tag, format: :json), xhr: true }
      before { subject }
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
          name: tag.name
        )
      end

    end
  end

  describe "#create" do
    subject { post api_v1_board_column_card_tags_path(board, column, card, tag: tag_params, format: :json), headers: token }
    let!(:tag_params) do
      { name: "hello" }
    end

    context 'without permission' do
      subject { post api_v1_board_column_card_tags_path(board, column, card, tag: tag_params, format: :json) }
      before { subject }
      it_behaves_like "a not authorized error"
    end

    context "correct params are passed" do
      it "has success status" do
        subject
        expect(response.status).to eq 200
      end
    end
    
    context "comment was created" do
      it "adds new record" do
        expect{ subject }.to change{ card.tags.count }.by(1)
      end

      it "has correct user and body" do
        subject
        expect(JSON.parse(response.body)).to include_json(
          name: "hello"
        )
      end
    end
  
    context "invalid params are passed" do
      subject { post api_v1_board_column_card_tags_path(board, column, card, tag: tag_params, format: :json), headers: token }
      let!(:tag_params) do
        { name: nil }
      end
      
      it "has unprocessable entity status" do
        subject
        expect(response.status).to eq 422
      end
  
      it "returns json with errors" do
        subject
        expect(JSON.parse(response.body)).to include_json(
            error: "Name is to short"
        )
      end

      it "not adds new tag" do
        expect{ subject }.to change(card.tags, :count).by(0)  
      end
    end
  end

  describe "#destroy" do
    subject { delete api_v1_board_column_card_tag_path(board, column, card, tag, format: :json), headers: token }

    before do
      card.tag_list.add("good")
      card.save
    end

    let!(:tag) { card.tags.find_by(name: 'good') }
    
    context 'without permission' do
      subject { delete api_v1_board_column_card_tag_path(board, column, card, tag, format: :json) }
      before { subject }
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
          message: "Tag successfully deleted."
        )
      end
    end

    context "comment deleted" do
      it "deletes record" do
        expect{ subject }.to change(card.tags, :count).by(-1)
      end
    end

  end

end
