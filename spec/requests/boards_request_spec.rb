require 'rails_helper'
require 'pp'

RSpec.describe BoardsController, type: :controller do

  login_user

  # Index
  describe "GET #index" do
    subject { get :index }

    context "redirected request - not authorized user" do
      it "is redirects user to login page" do
        sign_out controller.current_user
        subject
        expect(response.status).to eq(302)
        expect(response.status).to redirect_to new_user_session_path
      end
    end

    context "successful request" do
      it "returns successful response and renders index page" do
        subject
        expect(response.status).to eq(200)
        expect(response.status).to render_template(:index)
      end
    end
 
    context "without boards" do
      it "returns no boards" do
        subject
        expect(assigns(:boards)).to be_empty
      end
    end

    context "with 3 user boards" do
      let(:user_boards) { create_list(:board, 3, user: controller.current_user) }
      let(:random_boards) { create_list(:board, 3) }
      it "returns only 3 user boards" do
        subject
        expect(assigns(:boards)).to match_array(user_boards)
      end
    end

    context "with 3 public boards" do
      let(:boards) { create_list(:board, 3, public: true) }
      it "returns 3 public boards" do
        subject
        expect(assigns(:boards)).to match_array(boards)
      end
    end

    context "with only private boards" do
      let(:boards) { create_list(:board, 3) }
      it "returns no boards" do
        subject
        expect(assigns(:boards)).to_not match_array(boards)
      end
    end
  
  end # Close index tests
  
  # Show
  describe "GET #show" do
    subject { get :show, params: { id: board.id } }

    context "successful request - public board" do
      let(:board) { create(:board, public: true) }
      it "returns successful response  and renders show page" do     
        subject
        expect(response.status).to eq(200)
        expect(response.status).to render_template(:show)
      end
    end

    # context "redirected request - private board" do
    #   let(:board) { create(:board) }
    #   it "redirects to index" do
    #     subject
    #     expect(response.status).to eq(302)
    #     expect(response.status).to redirect_to action: :index
    #   end
    # end

    context "pass board with 10 columns" do
      let(:board) { create(:board_with_columns, public: true) }
      it "returs board with 10 columns" do
        subject
        expect(assigns(:columns).length).to eq(10)
      end
    end

    context "pass board" do
      let(:board) { create(:board, public: true) }
      it "returs valid board" do
        subject
        expect(assigns(:board)).to be_a(Board)
        expect(assigns(:board)).to eq(board)
      end
    end

  end # Close show tests

  # New
  describe "GET #new" do
    subject { get :new }

    context "successful request" do
      it "returns successful response and renders new form" do
        subject
        expect(response.status).to eq(200)
        expect(response).to render_template(:new)
      end

      it "sends a new boad" do
        subject
        expect(assigns(:board)).to be_a(Board)
        expect(assigns(:board)).to be_a_new(Board)
      end
    end
  end

  # Create
  describe "POST #create" do
    subject { post :create, params: { board: params } }
  
    context "pass valid params" do
      let(:params) do
        { title: "new board", description: "new board", public: true }
      end
      it "redirects to show page" do
        subject
        expect(response.status).to eq(302)
        expect(response.status).to redirect_to action: :show, id: assigns(:board).id
      end

      it "returns success flashes" do
        subject
        expect(flash[:success]).to include("Board successfully created!")
      end
    end

    context "pass invalid params" do
      let(:params) { { title: "", description: "", public: true } }
      it "renders new template" do
        subject
        expect(response.status).to render_template(:new)
      end
    end

  end # Close create tests
  
  # Edit
  describe "GET #edit" do
    subject { get :edit, params: { id: board.id } }
    let(:user) { controller.current_user }
    let(:membership) { create(:membership, user: user, board: board) }
    let(:board) { create(:board, user: user) }

    context "admin request" do
      it "returns successful response and renders edit form" do
        membership
        subject
        expect(response.status).to eq(200)
        expect(response).to render_template(:edit)
      end
    end

    context "not admin request" do
      it "redirects to show page" do
        subject
        expect(response.status).to eq(302)
        expect(response).to redirect_to action: :show, id: assigns(:board).id
      end
    end

    context "edit valid board" do
      it "returns valid board" do
        membership
        subject
        expect(assigns(:board)).to be_a(Board)
        expect(assigns(:board)).to eq(board)
      end
    end
  end # Close edit validations

  # Update
  describe "PUT #update" do
    subject { put :update, params: { id: board.id, board: params } }
    let(:user) { controller.current_user }
    let(:board) { create(:board, user: user) }
    let!(:membership) { create(:membership, user: user, board: board) }

    context "valid update params" do
      let(:params) do
        { title: "updated board", description: "updated board", public: true }
      end
     
      it "updates board with valid params" do
        subject
        board.reload
        expect(board.title).to eq(params[:title])
        expect(board.description).to eq(params[:description])
      end

      it "redirects to show page" do
        subject
        expect(response.status).to eq(302)
        expect(response.status).to redirect_to action: :show, id: assigns(:board).id
      end

      it "returns success flashes" do
        subject
        expect(flash[:success]).to include("Board successfully updated!")
      end
    end

    context "invalid update params" do
      let(:params) {  { title: "", description: "", public: true } }

      it "doesn't update board" do
        subject
        board.reload
        expect(board.title).to_not eq(params[:title])
        expect(board.description).to_not eq(params[:description])
      end

      it "renders edit" do
        subject
        expect(response.status).to render_template(:edit)
      end
    end

  end # Close update tests

  # Destroy
  describe "DELETE #destroy" do
    subject { delete :destroy, params: { id: board.id } }
    let(:user) { controller.current_user }
    let!(:board) { create(:board, user: user) }
    let!(:random_board) { create(:board, user: user) }

    context "user admin deletes board" do
      let!(:membership) { create(:membership, user: user, board: board) }
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

    context "user not admin" do
      it "redirects to show action" do
        subject
        expect(response.status).to eq(302)
        expect(response.status).to redirect_to action: :show, id: assigns(:board).id
      end
    end
  end # Close destroy tests

  # Members
  describe "GET #members" do
    subject { get :members, format: :json, params: { id: board.id } }
    let!(:user) { controller.current_user }
    let!(:board) { create(:board, user: user) }
    let!(:membership) { create(:membership, user: user, board: board) }
    let!(:memberhips) { create_list(:membership, 3, board: board) }

    context "valid requerst" do
      it "returns success" do
        subject 
        expect(response.status).to eq(200)
      end
    end

    context "create 3 users (4 with creater) in board membership" do
      
      it "returns 4 board members (users)" do
        subject
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.length).to eq(4)
      end
    end

    context "check particolar users in json" do
      it "returns 4 board members (users)" do
        subject
        parsed_response = JSON.parse(response.body)
        expect(parsed_response[0]['email']).to eq(user.email)
        expect(parsed_response[3]['email']).to eq(board.users.last.email)
      end
    end
    
  end # Close members

end
