require 'rails_helper'

RSpec.describe Boards::CreateService do
  
  let!(:user) { create(:user) }
  let(:board_params) { {title: 'some title', description: 'some description', public: true} }
  let!(:create_service) { Boards::CreateService.new(user, board_params) }

  describe "#call" do
    subject { create_service.call() }
    context 'board and user are correctly set' do

      it 'parameter user and board is valid' do
        expect(subject.memberships.find_by(user: user).admin).to eq(true)
      end

      it 'new membership is created' do
        expect(subject.memberships.first).to eq(user.memberships.first)
      end

      it 'create new membership in db' do
        expect{ subject }.to change(Membership, :count).by(1)
      end

      it 'create new board in db' do
        expect{ subject }.to change(Board, :count).by(1)
      end
    end
    
    context "with invalid attributes" do
      let(:board_params) { { description: 'bla' } }

      it "doesn\'t create new board and membership" do
        expect{ subject }.to_not change(Membership, :count)
        expect{ subject }.to_not change(Board, :count)
      end
    end 
  end
end
