require 'rails_helper'
require 'pp'

RSpec.describe "comments/_edit" do
  describe "page content" do
    let!(:membership) { create(:membership) }
    let!(:board) { membership.board }
    let!(:user) { membership.user }
    let!(:column) { create(:column, board: board, user: user) }
    let!(:card) { create(:card, column: column, user: user) }
    let!(:comment) { create(:comment, card: card, user: user) }

    before do
      sign_in user
      assign(:column, column)
      assign(:card, card)
      assign(:comment, comment)
      render partial: "comments/edit.html.haml"
    end

    context "has form" do
      it "contains comment-id" do
        expect(rendered).to have_tag("div.row#edit-form-#{comment.id}")
      end

      it "contains form group" do
        expect(rendered).to have_tag("div.col-sm-12 div.form-group.mb-3")
      end

      it "contains form fields" do
        expect(rendered).to have_tag('form', with: { action: "/boards/#{board.id}/columns/#{column.id}/cards/#{card.id}/comments/#{comment.id}", method: 'post' }) do
          with_tag "label", with: {for: "comment_Edit comment"}
          with_tag "input#comment_body", with: { name: "comment[body]", type:"text" }
          with_tag "input", with: { name: "commit", value: "Edit", type: "submit" }
        end
      end
    end
  end
end
