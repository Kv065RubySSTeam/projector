require 'rails_helper'

RSpec.describe MembershipsController, type: :controller do
  let(:current_user) { create(:user) }
 
  let!(:user) { current_user }
  let!(:user1) { create(:user) }
  let!(:board) { create(:board, user: user) }
  let!(:board1) { create(:board, user: user) }
  let!(:admin_member) { create(:admin_membership, user: user, board: board) }
 
  before do
    sign_in current_user
  end
  
  shared_examples "a redirect response" do
    it { expect(response.status).to eq(302) }
  end
  
  shared_examples "a success response" do
    it { expect(response.status).to eq(200) }
  end

  shared_examples "an unprocessable entity response" do
    it { expect(response.status).to eq(422) }
  end

  shared_examples "а not authorized error" do
    before(:each) do
      request.headers["HTTP_REFERER"] = "http://exapmpe.com/test"
      subject
    end
    it "shows not authorized flashes" do 
      expect(flash[:error]).to include("You are not authorized")
    end

    it { expect(response.location).to eq("http://exapmpe.com/test") }

    it { expect(response.status).to eq(302) }

  end

  it "should have a current_user" do
    expect(subject.current_user).to_not eq(nil)
  end

  describe "PUT #admin" do
    context 'when the board has admin and new user exist' do
      subject { put :admin, format: :json, params: { board_id: admin_member.board.id, id: user.id } }

      it "returns status code 200" do
        subject
        expect(response).to have_http_status(200)
      end
      it "returns an empty object" do
        subject
        expect(JSON.parse(response.body)).to eq({})
      end
      it "change board admin to false" do
        subject
        expect( board.memberships.find_by(user_id: user.id).admin ).to eq(false)
      end

    end

    context 'when the user is membeship but has admin false' do
      let!(:member) { create(:membership, user: user1,  board: board, admin: false ) }
      subject { put :admin, format: :json, params: { board_id: board.id, id: user1.id } }

      it "returns status code 200" do
        subject
        expect(response).to have_http_status(200)
      end
      it "returns an empty body" do
        subject
        expect(JSON.parse(response.body)).to eq({})
      end
      it 'returns admin true' do
        subject
        expect(board.memberships.find_by(user_id: user1.id).admin).to eq(true)
      end
      it 'returns admin true for default board admin' do
        subject
        expect(board.memberships.find_by(user_id: user.id).admin).to eq(true)
      end
    end

    context 'when the user is membeship and has admin true' do
      let!(:member1) { create(:membership, user: user1,  board: board, admin: true ) }
      subject { put :admin, format: :json, params: { board_id: board.id, id: user1.id } }

      it "returns status code 200" do
        subject
        expect(response).to have_http_status(200)
      end
      it "returns an empty body" do
        subject
         expect( JSON.parse(response.body) ).to eq({})
      end
      it 'returns admin false for new user' do
        subject
        expect( board.memberships.find_by(user: user1).admin ).to eq(false)
      end
      it 'returns admin true for board creator' do
        subject
        expect( board.memberships.find_by(user: user).admin ).to eq(true)
      end
    end

    context 'when board not have admin member' do
      subject { put :admin, format: :json, params: { board_id: board1.id, id: user1.id } }
      it "return http status a 401 error" do
        subject
        expect(response).to have_http_status(401)
      end
      it "returns an error Unauthorize" do
        subject
        expect( JSON.parse(response.body) ).to eq( {"error"=>"Unauthorize"} )
      end
    end
  end # close put validation

  describe "POST #create" do

    context 'when board and new user exist' do
      let!(:member1) { create(:admin_membership, user: user, board: board1) }
      subject { post :create, format: :json, params: { board_id: board1.id, id: user1.id } }
      it "returns created successfuly" do
        subject
        expect(response).to have_http_status(200)
      end
      it "returns an empty body" do
        subject
        expect( JSON.parse(response.body) ).to eq({})
      end
      it "returns two members" do
        subject
        expect( assigns(:board).memberships.length ).to eq(2)
      end
      it "returns new user present in board" do
        subject
        expect( board1.memberships.where(user: user1) ).to be_present
      end
      it "returns new user value as false" do
        subject
        expect( board1.memberships.find_by(user_id: user1.id ).admin).to eq(false)
      end
    end

    context 'when params invalid' do
      subject { post :create, format: :json, params: { board_id: board.id, id: user.id } }
      it "return Unprocessable Entity" do
        subject
        expect(response.status).to eq(422)
      end
      it "return response body as error" do
        subject
        expect( JSON.parse(response.body) ).to eq( {"error"=>["User has already been taken"]} )
      end

    end
  end #close post validation 
end
