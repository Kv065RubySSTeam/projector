require 'rails_helper'

RSpec.describe Board, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:columns).dependent(:destroy) }
  it { is_expected.to have_many(:memberships).dependent(:destroy) }
  it { is_expected.to have_many(:users).through(:memberships) }


  let(:board) { build(:board) }
  
  shared_examples "an object with errors" do
    it "returns appropriate error message" do
      board.update(data)
      expect(board.errors.to_a).to include(error_message)
    end
  end

  shared_examples "an object without errors" do
    it "doesn't return errors" do
      board.update(data)
      expect(board.errors.to_a).to be_empty
    end
  end


  describe "user presence" do

    context "without user" do
      it_behaves_like "an object with errors" do 
        let(:data) { { user: nil } }
        let(:error_message) { "User must exist" }
      end
    end

    context "with user" do
      it_behaves_like "an object without errors" do 
        let(:data) { { user: build(:user) } }
      end
    end
    
  end

  describe "title length" do

    context "short title" do
      it_behaves_like "an object with errors" do 
        let(:data) { { title: "a" } }
        let(:error_message) { "Title is too short (minimum is 5 characters)" }
      end
    end
  
    context "long title" do
      it_behaves_like "an object with errors" do 
        let(:data) { { title: "#{"a" * 51}" } }
        let(:error_message) { "Title is too long (maximum is 50 characters)" }

      end
    end

    context "valid title" do
      it_behaves_like "an object without errors" do 
        let(:data) { { title: "#{"a" * 25}" } }
      end
    end

  end

  describe "description length" do

    context "short description" do
      it_behaves_like "an object with errors" do 
        let(:data) { { description: "#{"a" * 3}" } }
        let(:error_message) { "Description is too short (minimum is 5 characters)" }
      end
    end

    context "long description" do
      it_behaves_like "an object with errors" do 
        let(:data) { { description: "#{"a" * 256}" } }
        let(:error_message) { "Description is too long (maximum is 255 characters)"}
      end
    end

    context "valid description" do
      it_behaves_like "an object without errors" do 
        let(:data) { { description: "#{"a" * 100}" } }
      end
    end

  end

  describe "#last_column_position" do
    subject { board.last_column_position }

    context "without colums" do
      let(:board) { create(:board) }
      it { is_expected.to be_nil }
    end
    
    # context "with columns" do
    #   let(:columns_quantity) { 10 }
    #   let(:board) { create(:board_with_columns, columns_count: columns_quantity) }
    #   it { expect(subject).to eq(columns_quantity) }
    # end 

  end
  
  describe "#search" do
    subject { Board.search(seach_phrase) }
    let!(:random_board) { create(:board) }
    let!(:matching_description) { create(:board, description: "hello") }
    let!(:matching_title) { create(:board, title: "hello") }

    context "appropriate search phrase" do
      let(:seach_phrase) { "hello" }
      it "is returns 2 apropriate boards" do
        expect(subject).to contain_exactly(matching_title, matching_description)
      end
    end

    context "inappropriate search phrase" do
      let(:seach_phrase) { "good bye" }
      it { is_expected.to be_empty }
    end 
  end

  describe "#user_boards" do
    subject { Board.user_boards(user) }
    let(:user) { build(:user) }
    let!(:random_user_board) { create(:board) }

    context "user with boards" do
      let!(:boards) { create_list(:board, 5, user: user) }
      it "is returns user boards length" do
        expect(subject.length).to eq(boards.length)
      end
    end

    context "user without boards" do
      let!(:boards) { create_list(:board, 5) }
      it "is returns no boards" do
        expect(subject.length).to eq(0)
      end
    end
  end

  describe "#public_boards" do
    subject { Board.public_boards }
    let!(:private_board) { create(:board, public: false) }

    context "pass 5 public boards" do
      it "is returns 5 public boards" do
        boards = create_list(:board, 5, public: true)
        expect(subject.length).to eq(boards.length)
      end
    end

    context "no public boards" do
      it "is returns no boards" do
        expect(subject.length).to eq(0)
      end
    end
  end

  describe "#private_boards" do
    subject { Board.private_boards }
    let!(:public_board) { create(:board, public: true) }

    context "pass 5 private boards" do
      it "is returns 5 private boards" do
        create_list(:board, 5, public: false)
        expect(subject.length).to eq(5)
      end
    end

    context "no private boards" do
      it "is returns no boards" do
        expect(subject.length).to eq(0)
      end
    end
  end

  describe "#public_and_user_boards" do
    subject { Board.membership_and_public_boards(user) }
    let!(:private_board) { create(:board, public: false) }
    let!(:user) { build(:user) }
    
    context "pass 3 approptiate boards" do
      let!(:user_public_board) { create(:board, user: user, public: true) }
      let!(:user_private_board) { create(:board, user: user) }
      let!(:membership) { create(:membership, user: user, board: board)}
      let!(:public_board) { create(:board, public: true) }
      
      it "is returns 3 boards" do
        expect(subject.length).to eq(3)
      end
    end

    context "have no appropreate boards" do
      it "is returns no boards" do
        expect(subject.length).to eq(0)
      end
    end
  end
  
  describe "#filter" do
    subject { Board.filter(filter, user) }
    let!(:user) { build(:user) }
    let!(:user_public_board) { create(:public_board, user: user) } 
    let!(:user_private_board) { create(:board, user: user) }
    let!(:membership) { create(:membership, user: user, board: user_private_board) }
    let!(:private_board) { create(:board) }
    let!(:public_board) { create(:public_board) }

    context "pass 'my'" do
      let(:filter) { "my" }
      it "is returns 2 user boards" do
        expect(subject).to contain_exactly(user_public_board, user_private_board)
      end
    end

    context "pass 'private'" do
      let(:filter) { "private" }
      it "is returns 1 user private board" do
        expect(subject).to contain_exactly(user_private_board)
      end
    end

    context "pass 'public'" do
      let(:filter) { "public" }
      it "is returns 2 public boards" do
        expect(subject).to contain_exactly(user_public_board, public_board)
      end
    end

    context "pass nothing" do
      let(:filter) { "" }
      it "is returns 2 public boards and 1 user private board" do
        expect(subject).to contain_exactly(user_public_board, user_private_board, public_board)
      end
    end
  end

  describe "#sorting" do
    subject { Board.sorting(data) }
    let!(:first_board) { create(:board) }
    let!(:second_board) { create(:board) }

    context "pass asc" do
      let(:data) { "asc" }
      it "is returns first board first" do
        expect(subject.first).to eq(first_board)
        expect(subject.last).to eq(second_board)
      end
    end

    context "pass desc" do
      let(:data) { "desc" }
      it "it returns second board fist" do
        expect(subject.first).to eq(second_board)
        expect(subject.last).to eq(first_board)
      end
    end
  end

end
