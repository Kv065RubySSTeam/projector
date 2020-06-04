require 'rails_helper'
require 'pp'

RSpec.describe "comments/_comment" do
  describe "page content" do
    let!(:membership) { create(:membership) }
    let!(:board) { membership.board }
    let!(:user) { membership.user }
    let!(:column) { create(:column, board: board, user: user) }
    let!(:card) { create(:card, column: column, user: user) }
    let!(:comment) { create(:comment, card: card, user: user) }

    before do
      assign(:column, column)
      assign(:card, card)
    end
    
    context "has tags" do
      before do
        sign_in user
        render partial: "comments/comment.html.haml", locals: {comment: comment}
      end

      it "contains comment-id" do
        expect(rendered).to have_tag("div.card-content#comment-#{comment.id}")
      end

      it "contains creator email" do
        expect(rendered).to have_tag("small", text: comment.user.email)
      end

      it "contains comment body" do
        expect(rendered).to have_tag("p", seen: comment.body)
      end

    end

    context "current user is a comment creator" do
      before do
        sign_in user
        render partial: "comments/comment.html.haml", locals: {comment: comment}
      end
      
      it "contains button with the link to edit form" do
        expect(rendered).to have_tag("a.btn.btn-outline-primary.btn-sm.d-inline", with: { href: "/boards/#{board.id}/columns/#{column.id}/cards/#{card.id}/comments/#{comment.id}/edit" }) do
        with_text "Edit"
        end
      end

      it "contains button with the link to delete comment" do
        expect(rendered).to have_tag("a.btn.btn-light-danger.btn-sm.d-inline", with: { href: "/boards/#{board.id}/columns/#{column.id}/cards/#{card.id}/comments/#{comment.id}" }) do
        with_text "Delete"
        end
      end
    end
    
    context "current user is not a comment creator" do
      let(:user2) { create(:user, confirmed_at: Time.now) }

      before do
        sign_in user2
        render partial: "comments/comment.html.haml", locals: {comment: comment}
      end

      it "not contains button with the link to edit form" do
        expect(rendered).to_not have_tag("a.btn.btn-outline-primary.btn-sm.d-inline", with: { href: "/boards/#{board.id}/columns/#{column.id}/cards/#{card.id}/comments/#{comment.id}/edit" }) do
        with_text "Edit"
        end
      end

      it "not contains button with the link to delete comment" do
        expect(rendered).to_not have_tag("a.btn.btn-light-danger.btn-sm.d-inline", with: { href: "/boards/#{board.id}/columns/#{column.id}/cards/#{card.id}/comments/#{comment.id}" }) do
        with_text "Delete"
        end
      end
    end
  end
end
