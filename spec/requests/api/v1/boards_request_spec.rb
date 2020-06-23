# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::BoardsController, type: :request do
  let(:user) { create(:user) }

  let(:token_new) { Users::CreateTokenService.call(user) }
  let(:token) do
    {  "Authorization" => "Bearer #{token_new}"  }
  end

  let(:board) { create(:board, user: user) }

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

  describe '#index' do
    subject { get api_v1_boards_path(user_id: user.id), headers: token }

    context 'with permission' do
      it 'has successful status' do
        subject
        expect(response.status).to eq(200)
      end

      it 'render correct template' do
        expect(subject).to render_template(:index)
      end
    end
  end

  describe '#show' do
    subject { get api_v1_board_path(id: board.id), headers: token }

    context 'with permission' do
      let(:board) { create(:board, public: true) }

      it 'has successful status' do
        subject
        expect(response.status).to eq(200)
      end

      it 'render correct template' do
        expect(subject).to render_template(:show)
      end
    end

    context 'without permission' do
      it_behaves_like 'not authorized error'
    end
  end

  describe '#create' do
    subject { post api_v1_boards_path(board: board_params), headers: token }

    context 'correct params are passed' do
      let(:board_params) do
        { "title": 'new board', "description": 'new board', "public": true, "user_id": user.id.to_s }
      end

      it 'has successful status' do
        subject
        expect(response.status).to eq(201)
      end

      it 'render correct jbuilder partial' do
        expect(subject).to render_template(:show)
      end

      it 'adds new object to db' do
        expect { subject }.to change(Board, :count).by(1)
      end
    end

    context 'pass invalid params' do
      let(:board) { create(:board) }

      let(:board_params) do
        { "title": '', "description": '', "public": true, "user_id": user.id.to_s }
      end

      let(:errors) do
        ['Title is too short (minimum is 5 characters)',
         'Description is too short (minimum is 5 characters)']
      end

      before do
        allow_any_instance_of(Boards::CreateService).to receive(:call).and_return(board)
        allow(board).to receive_message_chain(:errors, :empty?) { false }
        allow(board).to receive_message_chain(:errors, :full_messages) { errors }
      end

      it 'return bad params response' do
        subject
        expect(response.status).to eq(422)
      end

      it 'return correct error' do
        subject
        expect(JSON.parse(response.body)['errors']).to match_array(errors)
      end

      it 'does`t render jbuilder partial' do
        expect(subject).not_to render_template(:show)
      end

      it 'doesn\'t create new object' do
        expect { subject }.to change(Board, :count).by(0)
      end
    end
  end

  describe 'PUT #update' do
    subject { put api_v1_board_path(id: board.id, board: params), headers: token }

    let(:board) { create(:board, user: user) }
    let!(:membership) { create(:admin_membership, user: user, board: board) }

    context 'valid update params' do
      let(:params) do
        { title: 'updated board', description: 'updated board', public: true }
      end

      before(:each) { subject }

      it 'updates board with valid params' do
        board.reload
        expect(board.title).to eq(params[:title])
        expect(board.description).to eq(params[:description])
      end

      it 'returns success flashes' do
        expect(response).to have_http_status(200)
      end
    end

    context 'invalid update params' do
      let(:params) {  { title: '', description: '', public: true } }
      before(:each) { subject }
      let(:errors) do
        ['Title is too short (minimum is 5 characters)',
         'Description is too short (minimum is 5 characters)']
      end

      it "doesn't update board" do
        board.reload
        expect(board.title).to_not eq(params[:title])
        expect(board.description).to_not eq(params[:description])
      end

      it 'returns errors' do
        expect(assigns(:board).errors.to_a).to match_array(errors)
      end
    end
  end

  describe '#destroy' do
    subject { delete api_v1_board_path(id: board.id), headers: token }

    let!(:board) { create(:board, user: user) }
    let!(:random_board) { create(:board, user: user) }

    context 'user admin deletes board' do
      let!(:membership) { create(:admin_membership, user: user, board: board) }
      it 'deletes only particular board' do
        expect(Board.all).to include(board)
        subject
        expect(Board.all).to_not include(board)
      end

      it 'has successfully response body' do
        subject
        expect(json_response).to eq({ "message": 'Successfully deleted!' })
      end

      it 'has successfully deleted' do
        subject
        expect(response).to have_http_status(200)
      end
    end

    context 'invalid params' do
      let!(:membership) { create(:membership, user: user, board: board, admin: true) }

      before(:each) do
        allow_any_instance_of(Board).to receive(:destroy).and_return(false)
        subject
      end

      it 'deletes no objects' do
        expect { subject }.to_not change { Board.count }
      end
    end
  end

  describe '#members' do
    subject { get members_api_v1_board_path(id: board.id), headers: token }

    let!(:board) { create(:board, user: user) }
    let!(:membership) { create(:membership, user: user, board: board) }
    let!(:memberhips) { create_list(:membership, 3, board: board) }

    it 'has successful status' do
      subject
      expect(response.status).to eq(200)
    end

    it 'render correct temlate' do
      expect(subject).to render_template(:members)
    end

    it 'returns correct amount of board members' do
      subject
      parsed_response = JSON.parse(response.body)
      expect(parsed_response.length).to eq(4)
    end

    it 'returns correct board members' do
      subject
      parsed_response = JSON.parse(response.body)

      expect(parsed_response.map{ |user| user["email"] }).to eq(board.users.map(&:email))
    end
  end
end
