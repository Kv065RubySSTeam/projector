require 'rails_helper'
require 'pp'

RSpec.describe "comments/_form" do
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
      render partial: "comments/form.html.haml", locals: {comment: comment}
    end

    context "has form" do
      it "contains form group" do
        expect(rendered).to have_tag("div#comments-form div.form-group.mb-3")
      end

      it "contains form fields" do
        expect(rendered).to have_tag('form', with: { action: "/boards/#{board.id}/columns/#{column.id}/cards/#{card.id}/comments", method: 'post' }) do
          with_tag "label", with: {for: "comment_Comment"}
          with_tag "textarea#comment_body", with: { name: "comment[body]" }
          with_tag "input", with: { name: "commit", value: "Comment", type: "submit" }
        end
      end
    end
  end
end
