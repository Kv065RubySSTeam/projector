require "rails_helper"
require "pp"

RSpec.describe 'boards/edit.html.haml', type: :view do
  describe "/edit" do
    let(:boards) { create_list(:board, 5) }
    let(:board) { boards.sample }
    
    before(:each) do
      assign(:board, board)
      render
    end

    it "contains has appropriate title" do
      expect(rendered).to have_tag("h4", with: { class: 'card-title'}) do
         with_text "Edit board"
      end
    end

    it "contains form with method post" do
      expect(rendered).to have_tag("form", with: { class: "form-group", action: "/boards/#{board.id}", method: "post" })
    end

    it "contains input witn card title" do
      expect(rendered).to have_tag("input", with: { name: "board[title]", value: "#{board.title}" })
    end

    it "contains input with card description" do
      expect(rendered).to have_tag("textarea", with: { class: "form-control", name: "board[description]" })
      expect(rendered).to match("#{board.description}")
    end

    it "contains radio buttons" do
      expect(rendered).to have_tag("input", count: 2, with: { type: "radio", name: "board[public]" })
    end

    it "contains submit button" do
      expect(rendered).to have_tag("input", with: { type: "submit", value: "Edit board" })
    end

  end
end