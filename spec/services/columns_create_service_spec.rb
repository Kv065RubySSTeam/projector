require 'rails_helper'

RSpec.describe Columns::CreateService do
  describe "#call" do
    context 'board and user are correctly set' do

      subject { create_service }

      let(:create_service) { Columns::CreateService.call(board, user) }
      let(:user) { create(:user)}
      let(:board) { create(:board)}
      let!(:previous_column) { create(:column, board: board, position: 100) }

      it "sets expected default name" do
        expect(subject.name).to eq(Column::DEFAULT_TITLE)
      end

      it "sets expected position" do
        expect(subject.position).to eq(previous_column.position + 1)
      end

      it 'adds new object to db' do
        expect{ subject }.to change(Column, :count).by(1)  
      end
    end 
  end
end 