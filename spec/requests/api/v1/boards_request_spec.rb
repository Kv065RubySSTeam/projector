# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::BoardsController, type: :request do
  let(:current_user) { create(:user) }
  let(:user) { create(:user) }
  let(:board) { create(:board, user: user) }

  before do
    sign_in user
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

  describe '#index' do
    subject { get api_v1_boards_path(user_id: user.id) }

    context 'with permission' do
      it 'has successful status' do
        subject
        expect(response.status).to eq(200)
      end

      it 'render correct temlate' do
        expect(subject).to render_template(:index)
      end
    end
  end

  describe '#show' do
    subject { get api_v1_board_path(id: board.id) }

    context 'with permission' do
      let(:board) { create(:board, public: true) }

      it 'has successful status' do
        subject
        expect(response.status).to eq(200)
      end

      it 'render correct temlate' do
        expect(subject).to render_template(:show)
      end
    end

    context 'without permission' do
      it_behaves_like 'not authorized error'
    end
  end

  describe '#create' do
    subject { post api_v1_boards_path(board: board_params) }

    context 'correct params are passed' do
      let(:board_params) do
        { "title": 'new board', "description": 'new board', "public": true, "user_id": user.id.to_s }
      end

      it 'has successful status' do
        subject
        expect(response.status).to eq(201)
      end

      it 'render correct jbuilder partial' do
        expect(subject).to render_template(partial: '_board', locals: { board: board })
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
        expect(subject).not_to render_template(partial: '_board')
      end

      it 'doesn\'t create new object' do
        expect { subject }.to change(Board, :count).by(0)
      end
    end
  end

  describe 'PUT #update' do
    subject { put api_v1_board_path(id: board.id, board: params) }

    let(:user) { current_user }
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
    subject { delete api_v1_board_path(id: board.id), as: :json }

    let(:user) { current_user }
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
      let!(:membership) { create(:membership, user: current_user, board: board, admin: true) }

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
    subject { get members_api_v1_board_path(id: board.id) }

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
      expect(parsed_response.first['email']).to eq(user.email)
      expect(parsed_response.last['email']).to eq(board.users.last.email)
    end
  end
end
