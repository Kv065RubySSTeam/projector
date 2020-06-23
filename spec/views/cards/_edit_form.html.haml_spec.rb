require "rails_helper"

RSpec.describe 'cards/_edit_form.html.haml', type: :view do
  describe "page content" do   
    let!(:card) { create(:card_with_comments, :with_tags) }
    let!(:column) { card.column }
    let!(:board) { column.board }
    let!(:assignee) { card.assign!(current_user) }
    let!(:current_user) { card.user }

    before(:each) do
      sign_in current_user
      assign(:card, card)
      assign(:column, column)
      assign(:board, board)
      assign(:assignee, assignee)
      card.audits.delete_all
      render partial: "cards/edit_form.html.haml", locals: { card: card }
    end

    it 'contains an assignee' do
      expect(rendered).to have_tag('div', with: { class: 'assignee-in-sidebar' }) do
        expect(rendered).to have_tag('div', with: { class: 'align-items-center' }) do
          "Assignee:"
        end
        expect(rendered).to have_tag('img', with: { class: 'rounded', src: "/images/placeholder.jpg" })
      end
    end

    it "contains correct title" do
      expect(rendered).to have_tag('form', with: { class: "edit-form", action: "/boards/#{board.id}/columns/#{column.id}/cards/#{card.id}", method: 'post' }) do
        with_tag "label" do
          with_text "Title"
        end
        with_tag "input", with: { name: "card[title]", value: card.title }
      end
    end

    it "contains correct body" do
      expect(rendered).to include(ERB::Util.html_escape(card.body.body.to_html))
    end

    it "contains button save" do
      expect(rendered).to have_tag("button.btn.btn-primary.glow", action: "#/boards/#{board.id}/columns/#{column.id}/cards/#{card.id}/" ) do
        expect(rendered).to have_tag("i.bx.bx-send")
      end
    end

    it "contains button delete" do
      expect(rendered).to have_tag("a.btn.btn-light-danger", action: "#/boards/#{board.id}/columns/#{column.id}/cards/#{card.id}/" ) do
        expect(rendered).to have_tag("i.bx.bx-trash")
      end
    end

    it "contains tags area with three tags" do
      expect(rendered).to have_tag("div.tags-container") do
        expect(rendered).to have_tag("span.tag-item", count: 3)
      end
    end

    it "contains input for tag" do
      expect(rendered).to have_tag("input#tagName")
    end

    it "contains input for comment" do
      expect(rendered).to have_tag("textarea.form-control")
    end

    it "contains comment button" do
      expect(rendered).to have_tag("input", value: "Comment")
    end

    context "card with tabs" do
      let!(:card) { create(:card_with_comments, :with_tags) }
      it do "has history tab"
        expect(rendered).to have_tag("a",  with: { id: 'history-tab'} )
      end
      it do "has comments tab"
        expect(rendered).to have_tag("a", with: { id: 'comments-tab'} )
      end
    end

    context "card without tags" do
      let!(:card) { create(:card) }
      end
      it do "without tags"
        expect(rendered).not_to have_tag("tag")
      end
    end
end
