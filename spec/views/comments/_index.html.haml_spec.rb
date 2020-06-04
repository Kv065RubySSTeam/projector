require 'rails_helper'
require 'pp'

RSpec.describe "comments/_comment" do
  describe "page content" do
    let!(:membership) { create(:membership) }
    let!(:board) { membership.board }
    let!(:user) { membership.user }
    let!(:column) { create(:column, board: board, user: user) }
    let!(:card) { create(:card, column: column, user: user) }

    before do
      sign_in user
      assign(:column, column)
      assign(:card, card)
    end

    context "has 5 comments" do
      before do
        create_list(:comment, 5, card: card, user: user)
        assign(:comments, Comment.paginate(page: 1))
        render partial: "comments/index.html.haml"
      end
      it "contains 5 tags" do
        expect(rendered).to have_tag("div.card-content", count: 5)
      end
    end

    context "without comments" do
      before do
        assign(:comments, Comment.paginate(page: 1))
        render partial: "comments/index.html.haml"
      end
      
      it "returns no comments " do
        expect(rendered).to_not have_tag("div.card-content")
      end

      it "no button present" do
        expect(rendered).to_not have_tag("a", with: { href: "/boards/#{board.id}/columns/#{column.id}/cards/#{card.id}/comments?page=2" }) do
          with_text "Load more"
        end
      end
    end

    context "with pagination" do
      before do
        create_list(:comment, 7, card: card, user: user)
        assign(:comments, Comment.paginate(page: 1))
        render partial: "comments/index.html.haml"
      end

      it "has button" do
        expect(rendered).to have_tag("a", with: { href: "/boards/#{board.id}/columns/#{column.id}/cards/#{card.id}/comments?page=2" }) do
          with_text "Load more"
        end
      end
    end

    context "without pagination" do
      before do
        create_list(:comment, 4, card: card, user: user)
        assign(:comments, Comment.paginate(page: 1))
        render partial: "comments/index.html.haml"
      end

      it "no button present" do
        expect(rendered).to_not have_tag("a", with: { href: "/boards/#{board.id}/columns/#{column.id}/cards/#{card.id}/comments?page=2" }) do
          with_text "Load more"
        end
      end
    end
  end
end
