require "rails_helper"

RSpec.describe 'boards/index.html.haml', type: :view do
  describe "index page with 12 user boards" do
    let(:user) { create(:user) }
    let!(:private_boards) { create_list(:board, 3, public: false) }
    let!(:memberships) { create_list(:membership, 12, user: user) }
    let!(:boards) { user.boards }
    
    before(:each) do
      allow(view).to receive(:current_user).and_return(user)
      assign(:boards, Board.filter("", user).paginate(page: 1))
      render
    end

    describe "buttons and links" do
      it "contains button with the link to new form" do
        expect(rendered).to match("/boards/new")
        expect(rendered).to match("Add New Board")
      end

      it "contains filter button for public" do
        expect(rendered).to have_tag("a", with: { href: "/" }) do
          with_text "All boards"
        end
      end
    end

    describe "boards list" do
      it "shows 10 boards links" do
        expect(rendered).to have_tag("a", count: 10, with: { id: "new_board_link" })
      end
    end

    describe "filters" do
      it "contains filter button for user boards" do
        expect(rendered).to have_tag("a", with: { href: "/?filter=my" }) do
          with_text "My boards"
        end
      end

      it "contains filter button for private boards" do
        expect(rendered).to have_tag("a", with: { href: "/?filter=private" }) do
          with_text "Private boards"
        end
      end
 
      it "contains filter button for public" do
        expect(rendered).to have_tag("a", with: { href: "/?filter=public" }) do
          with_text "Public boards"
        end
      end
    end

    describe "search form" do
      it "contains search form" do
        expect(rendered).to have_tag("form", with: { action: "/boards", method: "get" })
      end

      it "contains search input" do
        expect(rendered).to have_tag("input", with: { type: "text", name: "search" })
      end
    end

    describe "sorting" do
      it "contains ascending button" do
        expect(rendered).to have_tag("a", with: { href: "/?sort=asc" }) do
          with_text "Ascending"
        end
      end

      it "contains ascending button" do
        expect(rendered).to have_tag("a", with: { href: "/?sort=desc" }) do
          with_text "Descending"
        end
      end
    end
  end
end
