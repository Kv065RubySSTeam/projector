require 'rails_helper'

RSpec.describe BoardsController, type: :controller do
  let(:current_user) { create(:user) }

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
  
  describe "GET #index" do
    subject { get :index }
    let!(:random_boards) { create_list(:board, 3) }

    context "user doesn't exist" do
      before(:each) do 
        sign_out current_user
        subject
      end
      it "redirects to login page" do
        expect(response.status).to redirect_to new_user_session_path
      end
      it_behaves_like "a redirect response"
    end

    context "user exists" do
      before(:each) { subject }
      it "returns successful response and renders index page" do
        expect(response.status).to render_template(:index)
      end
    end

    context "only private not current user boards" do
      it "returns no boards" do
        subject
        expect(assigns(:boards)).to be_empty
      end
    end

    context "with 3 user boards" do
      let(:user) { create(:user_with_boards) }
      it "returns only 3 user boards" do
        subject
        expect(assigns(:boards)).to match_array(user.boards)
        expect(assigns(:boards)).to_not match_array(random_boards)
      end
    end

    context "with 3 public boards" do
      let!(:public_boards) { create_list(:board, 3, public: true) }
      it "returns 3 public boards" do
        subject
        expect(assigns(:boards)).to match_array(public_boards)
        expect(assigns(:boards)).to_not match_array(random_boards)
      end
    end

  end

  describe "GET #index pagination test" do
    let!(:boards) { create_list(:board, 15, public: true) }

    context "first page with 10 boards" do
      subject { get :index, params: { page: 1 } }
      it "returns only 10 boards" do
        subject
        expect(assigns(:boards).length).to eq(10)
      end
    end

    context "second page with 5 boards" do
      subject { get :index, params: { page: 2 } }
      it "returns only 5 boards" do
        subject
        expect(assigns(:boards).length).to eq(5)
      end
    end
  end

  describe "GET #show" do
    subject { get :show, params: { id: board.id } }
    before(:each) { subject }

    context "successful request - public board" do
      let!(:board) { create(:board, public: true) }
      it "returns successful response  and renders show page" do
        expect(response.status).to render_template(:show)
      end

      it_behaves_like "a success response"
    end

    context "pass board with 10 columns" do
      let(:board) { create(:board_with_columns, public: true) }
      it "returs board with 10 columns" do
        expect(assigns(:columns).length).to eq(10)
      end
    end

    context "pass board" do
      let(:board) { create(:board, public: true) }
      it "returs valid board" do
        expect(assigns(:board)).to be_a(Board)
        expect(assigns(:board)).to eq(board)
      end
    end

  end

  describe "GET #new" do
    subject { get :new }
    before(:each) { subject }

    context "successful request" do
      it "returns successful response and renders new form" do
        expect(response).to render_template(:new)
      end

      it_behaves_like "a success response"

      it "sends a new boad" do
        expect(assigns(:board)).to be_a(Board)
        expect(assigns(:board)).to be_a_new(Board)
      end
    end
  end

  describe "POST #create" do
    subject { post :create, params: { board: params } }

    context "pass valid params" do
      let(:params) do
        { title: "new board", description: "new board", public: true }
      end
      before(:each) { subject }

      it "redirects to show page" do
        expect(response.status).to redirect_to action: :show, id: assigns(:board).id
      end

      it_behaves_like "a redirect response"

      it "returns success flashes" do
        expect(flash[:success]).to include("Board successfully created!")
      end
    end

    context "pass invalid params" do
      let(:params) { { title: "", description: "", public: true } }
      before(:each) { subject }
      let(:errors) do
        ["Title is too short (minimum is 5 characters)",
          "Description is too short (minimum is 5 characters)"]
      end

      it "renders new template" do
        expect(response.status).to render_template(:new)
      end

      it_behaves_like "an unprocessable entity response"

      it "returns errors" do
        expect(assigns(:board).errors.to_a).to match_array(errors)
      end
    end
  
  end
  
  describe "GET #edit" do
    subject { get :edit, params: { id: board.id } }
    let(:user) { current_user }
    let(:admin_membership) { create(:admin_membership, user: user, board: board) }
    let(:board) { create(:board, user: user) }
  
    context "admin request" do
      before(:each) do
        admin_membership
        subject
      end
      it "returns successful response and renders edit form" do
        expect(response).to render_template(:edit)
      end

      it_behaves_like "a success response"
    end

    context "not admin request" do
      let!(:membership) { create(:membership, user: user, board: board) }
      it_behaves_like "а not authorized error"
    end

    context "edit valid board" do
      it "returns valid board" do
        admin_membership
        subject
        expect(assigns(:board)).to be_a(Board)
        expect(assigns(:board)).to eq(board)
      end
    end
  end

  describe "PUT #update" do
    subject { put :update, params: { id: board.id, board: params } }
    let(:user) { current_user }
    let(:board) { create(:board, user: user) }
    let!(:membership) { create(:admin_membership, user: user, board: board) }

    context "valid update params" do
      let(:params) do
        { title: "updated board", description: "updated board", public: true }
      end
      before(:each) { subject }
     
      it "updates board with valid params" do
        board.reload
        expect(board.title).to eq(params[:title])
        expect(board.description).to eq(params[:description])
      end

      it "redirects to show page" do
        expect(response.status).to redirect_to action: :show, id: assigns(:board).id
      end

      it_behaves_like "a redirect response"

      it "returns success flashes" do
        expect(flash[:success]).to include("Board successfully updated!")
      end
    end

    context "invalid update params" do
      let(:params) {  { title: "", description: "", public: true } }
      before(:each) { subject }
      let(:errors) do
        ["Title is too short (minimum is 5 characters)",
          "Description is too short (minimum is 5 characters)"]
      end

      it "doesn't update board" do
        board.reload
        expect(board.title).to_not eq(params[:title])
        expect(board.description).to_not eq(params[:description])
      end

      it "renders edit" do
        expect(response.status).to render_template(:edit)
      end

      it_behaves_like "an unprocessable entity response"

      it "returns errors" do
        expect(assigns(:board).errors.to_a).to match_array(errors)
      end
    end

  end

  describe "DELETE #destroy" do
    subject { delete :destroy, format: :js, params: { id: board.id } }
    let(:user) { current_user }
    let!(:board) { create(:board, user: user) }
    let!(:random_board) { create(:board, user: user) }
    
    context "user admin deletes board" do
      let!(:membership) { create(:admin_membership, user: user, board: board) }
      it "deletes only particular board" do
        expect(Board.all).to include(board)
        subject
        expect(Board.all).to_not include(board)
      end

      it "redirects to index page" do
        subject
        expect(response).to redirect_to root_path
      end

      it "shows success flashes" do
        subject
        expect(flash[:success]).to eq("Board successfully deleted!")
      end
    end

    context "invalid params" do
      let!(:membership) { create(:membership, user: current_user, board: board, admin: true) }

      before(:each) do
        allow_any_instance_of(Board).to receive(:destroy).and_return(false)
        subject
      end

      it_behaves_like "an unprocessable entity response"

      it "returns error flashes" do
        expect(flash[:error]).to include("Board has not been deleted! Something went wrong")
      end

      it "deletes no objects" do
        expect { subject }.to_not change { Board.count }  
      end
    end

    context "user not admin" do
      it_behaves_like "а not authorized error"
    end
  end

  describe "GET #members" do
    subject { get :members, format: :json, params: { id: board.id } }
    let!(:user) { current_user }
    let!(:board) { create(:board, user: user) }
    let!(:membership) { create(:membership, user: user, board: board) }
    let!(:memberhips) { create_list(:membership, 3, board: board) }
    before(:each) { subject }

    context "valid requerst" do
      it_behaves_like "a success response"
    end

    context "create 3 users (4 with creater) in board membership" do
      
      it "returns 4 board members (users)" do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.length).to eq(4)
      end
    end

    context "check particolar users in json" do
      it "returns 4 board members (users)" do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.first['email']).to eq(user.email)
        expect(parsed_response.last['email']).to eq(board.users.last.email)
      end
    end
    
  end
end
