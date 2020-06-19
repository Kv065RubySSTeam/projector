# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Columns', type: :request do
  let!(:membership) { create(:membership) }
  let!(:board) { membership.board }
  let!(:user) { membership.user }
  let!(:column) { create(:column, board: board, user: user) }

  before do
    sign_in user
  end

  shared_examples 'not authorized error' do
    let(:user) { create(:user) }
    let(:board) { create(:board, user: user) }

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

  describe '#create' do
    subject do
      post "/api/v1/boards/#{board.id}/columns",
           params: { "column": { "user_id": user.id.to_s } }
    end

    context 'correct params are passed' do
      it 'has successful status' do
        subject
        expect(response.status).to eq(201)
      end

      it 'render correct jbuilder partial' do
        expect(subject).to render_template(partial: '_column', locals: { column: column })
      end

      it 'adds new object to db' do
        expect { subject }.to change(Column, :count).by(1)
      end
    end

    context 'invalid params are passed' do
      let(:errors) { ['Invalid params'] }
      let(:column) { create(:column) }

      before do
        allow_any_instance_of(Columns::CreateService).to receive(:call).and_return(column)
        allow(column).to receive_message_chain(:errors, :empty?) { false }
        allow(column).to receive_message_chain(:errors, :full_messages) { errors }
      end

      it 'return bad params response' do
        subject
        expect(response.status).to eq(422)
      end

      it 'return correct error' do
        subject
        expect(JSON.parse(response.body)['errors']).to contain_exactly(errors.join("\n"))
      end

      it 'does`t render jbuilder partial' do
        expect(subject).not_to render_template(partial: '_column')
      end

      it 'doesn\'t create new object' do
        expect { subject }.to change(Column, :count).by(0)
      end
    end

    context 'without permission' do
      it_behaves_like 'not authorized error'
    end
  end

  describe '#update' do
    subject do
      patch "/api/v1/boards/#{board.id}/columns/#{column.id}",
            params: { "column": name_param }
    end

    context 'correct params are passed' do
      let(:name_param) do
        { "name": 'updated board' }
      end

      it 'has successful status' do
        subject
        expect(response.status).to eq(200)
      end

      it 'render correct jbuilder partial' do
        expect(subject).to render_template(partial: '_column', locals: { column: column })
      end

      it 'change name' do
        expect { subject }.to change { column.reload.name }
          .from(column.name)
          .to(name_param[:name])
      end
    end

    context 'invalid params are passed' do
      let(:name_param) do
        { "name": 'u' }
      end

      it 'return bad params response' do
        subject
        expect(response.status).to eq(422)
      end

      it 'return correct error' do
        subject
        expect(JSON.parse(response.body)['errors']).to contain_exactly(
          'Name is too short (minimum is 2 characters)'
        )
      end

      it 'does`t render jbuilder partial' do
        expect(subject).not_to render_template(partial: '_column')
      end

      it 'doesn\'t change name' do
        expect { subject }.not_to change { column.reload.name }
      end
    end

    context 'without permission' do
      it_behaves_like 'not authorized error' do
        let(:name_param) { { "name": "doesn't matter what" } }
      end
    end
  end

  describe '#destroy' do
    subject { delete "/api/v1/boards/#{board.id}/columns/#{column.id}" }

    context 'correct params are passed' do
      it 'has successful status' do
        subject
        expect(response.status).to eq(200)
      end

      it 'sets successful flash' do
        subject
        expect(JSON.parse(response.body)['message']).to eq('Successfully deleted!')
      end

      it 'delete object from db' do
        expect { subject }.to change(Column, :count).by(-1)
      end
    end

    context 'invalid params are passed' do
      let(:errors) { ['Invalid params'] }

      before do
        allow_any_instance_of(Column).to receive(:destroy).and_return(false)
        allow_any_instance_of(Column).to receive_message_chain(:errors, :full_messages) { errors }
      end

      it 'return bad params response' do
        subject
        expect(response.status).to eq(422)
      end

      it 'return correct error' do
        subject
        expect(JSON.parse(response.body)['errors']).to contain_exactly(errors.join("\n"))
      end

      it 'doesn\'t delete any object' do
        expect { subject }.to change(Column, :count).by(0)
      end
    end

    context 'without permission' do
      it_behaves_like 'not authorized error'
    end
  end
end
