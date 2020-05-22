require 'rails_helper'

RSpec.describe Board, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:columns).dependent(:destroy) }
  it { is_expected.to have_many(:memberships).dependent(:destroy) }
  it { is_expected.to have_many(:users).through(:memberships) }

  let(:board) { build(:board) }

  # Start board validations
  describe "Validations" do
    subject { board.errors.to_a }
    before { board.update(data) }

    # User presence validations
    describe "User presence" do
      context "without" do
        let(:data) { { user: nil } }
        it "is invalid without creater" do
          expect(subject).to include("User must exist")  
        end
      end
      context "with" do
        let(:data) { { user: build(:user) } }
        it "is valid with creater" do
          expect(subject).to be_empty
        end
      end
    end

    # Title length validations
    describe "Title length" do
      context "short" do
        let(:data) { { title: "a" } }
        it "is invalid with title less than 5 symbols" do
          expect(subject).to include("Title is too short (minimum is 5 characters)") 
        end
      end
    
      context "long" do
        let(:data) { { title: "#{"a" * 51}" } }
        it "is invalid with title more than 50 symbols" do
          expect(subject).to include("Title is too long (maximum is 50 characters)")
        end
      end

      context "valid" do
        let(:data) { { title: "#{"a" * 25}" } }
        it "is valid with title from 5 to 50 symbols" do
          expect(subject).to be_empty
        end
      end
    end

    # Description length validations
    describe "Description length" do
      context "short" do
        let(:data) { { description: "" } }
        it "is invalid with description more than 5 symbols" do
          expect(subject).to include("Description is too short (minimum is 5 characters)") 
        end
      end

      context "long" do
        let(:data) { { description: "#{"a" * 256}" } }
        it "is invalid with description less than 255 symbols" do
          expect(subject).to include("Description is too long (maximum is 255 characters)") 
        end
      end

      context "valid" do
        let(:data) { { description: "#{"a" * 100}" } }
        it "is valid with description from 5 to 255 symbols" do 
          expect(subject).to be_empty
        end
      end

    end

  end # Close board validations

  # Methods
  describe "Methods" do
    describe "#last_column_position" do
      subject { board.last_column_position }

      context "without colums" do
        let(:board) { create(:board) }
        it { is_expected.to be_nil }
      end
      
      context "with 10 columns" do
        let(:board) { create(:board_with_columns) }
        it { expect(subject).to eq(10) }
      end 

    end
  end # Close board methods

  # Scopes
  describe "Scopes" do

    # Search
    describe "#search" do
      subject { Board.search("hello") }
      let!(:random_board) { create(:board) }
      let!(:matching_description) { create(:board, description: "hello") }
      let!(:matching_title) { create(:board, title: "hello") }

      context "finds 2 boards" do
        it "is returns 2 apropriate boards" do
          expect(subject).to contain_exactly(matching_title, matching_description)
        end
      end

      context "finds nothing" do
        subject { Board.search("good bye") }
        it "is returns no boards" do
          expect(subject).to be_empty
        end
      end 
    end

    # Scopes for filter
    describe "#user_boards" do
      subject { Board.user_boards(user) }
      let(:user) { build(:user) }
      let!(:random_user_board) { create(:board) }

      context "user with 5 boards" do
        it "is returns 5 user boards" do
          5.times { create(:board, user: user) }
          expect(subject.length).to eq(5)
        end
      end

      context "user without boards" do
        it "is returns no boards" do
          5.times { create(:board) }
          expect(subject.length).to eq(0)
        end
      end
    end

    describe "#public_boards" do
      subject { Board.public_boards }
      let!(:private_board) { create(:board, public: false) }

      context "pass 5 public boards" do
        it "is returns 5 public boards" do
          5.times { create(:board, public: true) }
          expect(subject.length).to eq(5)
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
          5.times { create(:board, public: false) }
          expect(subject.length).to eq(5)
        end
      end

      context "no private boards" do
        it "is returns no boards" do
          expect(subject.length).to eq(0)
        end
      end
    end

    describe "#all_boards" do
      subject { Board.all_boards(user) }
      let!(:private_board) { create(:board, public: false) }
      let!(:user) { build(:user) }
      
      context "pass 3 approptiate boards" do
        let!(:user_public_board) { create(:board, user: user, public: true) }
        let!(:user_private_board) { create(:board, user: user) }
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
    
    # Filter
    describe "#filter" do
      subject { Board.filter(data, user) }
      let!(:user) { build(:user) }
      let!(:user_public_board) { create(:board, user: user, public: true) }
      let!(:user_private_board) { create(:board, user: user) }
      let!(:private_board) { create(:board, public: false) }
      let!(:public_board) { create(:board, public: true) }

      context "pass 'my'" do
        let(:data) { "my" }
        it "is returns 2 user boards" do
          expect(subject).to contain_exactly(user_public_board, user_private_board)
        end
      end

      context "pass 'private'" do
        let(:data) { "private" }
        it "is returns 1 user private board" do
          expect(subject).to contain_exactly(user_private_board)
        end
      end

      context "pass 'public'" do
        let(:data) { "public" }
        it "is returns 2 public boards" do
          expect(subject).to contain_exactly(user_public_board, public_board)
        end
      end

      context "pass nothing" do
        let(:data) { "" }
        it "is returns 2 public boards and 1 user private board" do
          expect(subject).to contain_exactly(user_public_board, user_private_board, public_board)
        end
      end
    end

    # Sorting
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

  end # Close board scopes

end