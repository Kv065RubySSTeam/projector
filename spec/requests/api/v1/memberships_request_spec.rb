# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MembershipsController, type: :request do
  let(:current_user) { create(:user) }

  let!(:user) { current_user }
  let!(:user1) { create(:user) }

  let!(:board) { create(:board, user: user) }
  let!(:board1) { create(:board, user: user) }

  let!(:admin_member) { create(:admin_membership, user: user, board: board) }

  let(:token_new) { Users::CreateTokenService.call(current_user) }
  let(:token) do
    {  "Authorization" => "Bearer #{token_new}"  }
  end

  describe 'POST #create' do
    context 'when board and new user exist' do
      let!(:member1) { create(:admin_membership, user: user, board: board1) }

      subject do
        post api_v1_board_memberships_path(board_id: board1.id, user_id: user1.id),
          headers: token
      end

      it 'has created successfuly' do
        subject
        expect(response).to have_http_status(201)
      end

      it 'returns two members' do
        subject
        expect(assigns(:board).memberships.length).to eq(2)
      end

      it 'returns new user present in board' do
        subject
        expect(board1.memberships.where(user: user1)).to be_present
      end

      it 'returns new user value as false' do
        subject
        expect(board1.memberships.find_by(user_id: user1.id).admin).to eq(false)
      end
    end

    context 'when params invalid' do
      subject do
        post api_v1_board_memberships_path(board_id: board.id, user_id: user.id),
          headers: token
      end

      it 'return Unprocessable Entity' do
        subject
        expect(response.status).to eq(422)
      end

      it 'return response body as error' do
        subject
        expect(json_response).to eq({ errors: ['User has already been taken'] })
      end
    end
  end

  describe 'PATCH #admin' do
    context 'when the board has admin and new user exist' do
      subject do
        patch admin_api_v1_board_membership_path(board_id: board.id, id: user.id),
          params: { user_id: user.id },
          headers: token
      end

      it 'returns status code 200' do
        subject
        expect(response).to have_http_status(200)
      end

      it 'change board admin to false' do
        subject
        expect(board.memberships.find_by(user_id: user.id).admin).to eq(false)
      end
    end

    context 'when the user is membership and has admin rights' do
      let!(:member1) { create(:membership, user: user1,  board: board, admin: true) }

      subject do
        patch admin_api_v1_board_membership_path(board_id: board.id, id: user1.id),
          params: { user_id: user1.id },
          headers: token
      end

      it 'returns status code 200' do
        subject
        expect(response).to have_http_status(200)
      end

      it 'returns admin false for new user' do
        subject
        expect(board.memberships.find_by(user: user1).admin).to eq(false)
      end

      it 'returns admin true for board creator' do
        subject
        expect(board.memberships.find_by(user: user).admin).to eq(true)
      end
    end

    context 'when board not have admin member' do
      subject do
        patch admin_api_v1_board_membership_path(board_id: board1.id, id: user1.id),
          params: { user_id: user1.id },
          headers: token
      end

      it 'return http status a 401 error' do
        subject
        expect(response).to have_http_status(401)
      end

      it 'returns an error Unauthorize' do
        subject
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorize' })
      end
    end
  end
end
