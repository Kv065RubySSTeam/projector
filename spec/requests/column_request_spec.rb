require 'rails_helper'
require 'pp'

RSpec.describe "Columns", type: :request do
  let!(:membership) { create(:membership) }
  let!(:board) { membership.board }
  let!(:user) { membership.user }
  let!(:column) { create(:column, board: board, user: user) }

  let(:referer) { 'http://example.com/test' }

  before do
    sign_in user
  end

  shared_examples "not authorized error" do
    let(:user) { create(:user) }
    let(:board) { create(:board, user: user) }

    before do
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

  describe "#create" do
    subject { post board_columns_path(board, format: :js), headers: { 'HTTP_REFERER': referer } }

    context 'correct params are passed' do
      it 'has successful status' do
        subject
        expect(response.status).to eq(200)
      end

      it 'sets successful flash' do
        subject
        expect(controller).to set_flash[:success].to("Column was successfully created.")
      end

      it 'adds new object to db' do
        expect{subject}.to change(Column, :count).by(1)  
      end
    end

    context 'invalid params are passed' do
      let(:errors) { ["Invalid params"] }
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

      it 'sets error flash' do
        subject
        expect(controller).to set_flash[:error].to(errors.join("\n"))
      end

      it 'doesn\'t create new object' do
        expect{subject}.to change(Column, :count).by(0)  
      end
    end

    context 'without permission' do
      it_behaves_like "not authorized error"
    end
  end

  describe "#update" do
    subject { patch board_column_path(board, column, column: params, format: :js), 
              headers: { 'HTTP_REFERER': referer } }

    context 'correct params are passed' do  
      let(:params) do
        { name: "updated board" }
      end

      it 'has successful status' do
        subject
        expect(response.status).to eq(200)
      end

      it 'sets successful flash' do
        subject
        expect(controller).to set_flash[:success].to("Column was successfully updated.")
      end

      it 'change name' do 
        expect{ subject }.to change{ column.reload.name }
                         .from(column.name)
                         .to(params[:name])
      end
    end

    context 'invalid params are passed' do
      let(:params) do
        { name: "u" }
      end

      it 'return bad params response' do
        subject
        expect(response.status).to eq(422)
      end

      it 'sets error flash' do
        subject
        expect(controller).to set_flash[:error].to("Name is too short (minimum is 2 characters)")
      end

      it 'doesn\'t change name' do 
        expect{ subject }.not_to change{ column.reload.name }
      end
    end

    context 'without permission' do
      it_behaves_like "not authorized error" do
        let(:params) {{ name: "doesn't matter what" }}
      end
    end
  end

  describe "#destroy" do
    subject { delete board_column_path(board, column, format: :js), 
              headers: { 'HTTP_REFERER': referer } } 

    context 'correct params are passed' do  
      it 'has successful status' do
        subject
        expect(response.status).to eq(200)
      end

      it 'sets successful flash' do
        subject
        expect(controller).to set_flash[:success].to("Column was successfully deleted!")
      end

      it 'delete object from db' do
        expect{subject}.to change(Column, :count).by(-1)
      end
    end

    context 'invalid params are passed' do
      before do
        allow_any_instance_of(Column).to receive(:destroy).and_return(false)
      end

      it 'return bad params response' do
        subject
        expect(response.status).to eq(422)
      end

      it 'sets error flash' do
        subject
        expect(controller).to set_flash[:error]
      end

      it 'doesn\'t delete any object' do
        expect{subject}.to change(Column, :count).by(0)  
      end
    end

    context 'without permission' do
      it_behaves_like "not authorized error"
    end
  end
end
