require "rails_helper"

RSpec.describe 'cards/index.html.haml', type: :view do
  describe "page content" do
    let!(:user) { build(:user) }
    let!(:board) { create(:board_with_cards, user: user) }
    let!(:membership) { create(:membership, user: user, board: board) }
    let!(:cards) { Card.available_for(user)}
    let!(:current_page) { 1 }
    let!(:next_page) { 2 }
    let!(:total_pages) { 3 }

    before(:each) do
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:sortable).and_return(link_to "Title", {sort: "title", direction: "asc", load_new: true, page: 1 }, {remote: true})
      assign(:current_page, current_page)
      assign(:next_page, next_page)
      assign(:total_pages, cards.count / 10)
      assign(:cards, cards)
      assign(:board, board)
      assign(:load_new, true)
      render
    end

    describe "all cards" do
      it "renders input" do
        expect(rendered).to have_tag("input", with: { id: 'search' })
      end
      it "orders cards by position updated_at desc" do
        expect(rendered).to have_tag("th", with: { class: "sorting_desc", "data-name": "updated_at" })
      end
    end

    describe "card-column" do
      it "orders cards by title asc" do
        cards[0..9].each do |card|
          expect(rendered).to have_tag("td", with: { class: "card-title"}) do
            "#{card.title}"
          end
          expect(rendered).to have_tag("td", with: { class: "card-body"}) do
            "#{card.body}"
          end
          expect(rendered).to have_tag("small", with: { class: "text-muted"}) do
            "#{card.created_at}"
          end
          expect(rendered).to have_tag("span", with: { class: "invoice-customer"}) do
            "#{user.full_name}"
          end
          expect(rendered).to have_tag("img", with: { src: "/images/placeholder.jpg"})
        end
      end
    end
  end
end
