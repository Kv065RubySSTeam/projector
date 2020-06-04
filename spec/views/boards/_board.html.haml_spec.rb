require "rails_helper"

RSpec.describe 'boards/_board.html.haml', type: :view do
  describe "page content" do
    let(:user) { build(:user) }
    let!(:public_boards) { create_list(:board, 3, public: true) }
    let!(:user_private_boards) { create_list(:board, 2, user: user) }
    let(:boards) { Board.filter("", user) }


    before do
      allow(view).to receive(:current_user).and_return(user)
      render partial: "boards/board.html.haml", locals: {boards: boards}
    end

    it "boards links with appropriate board titles" do
      boards.each do |board| 
        expect(rendered).to have_tag("a", with: { id: "new_board_link", href: "/boards/#{board.id}" })
        expect(rendered).to match("#{board.title}")
      end
    end

    it "shows all public and user title links" do
      expect(rendered).to have_tag("a", count: boards.length, with: { id: "new_board_link" })
    end

  end
end
