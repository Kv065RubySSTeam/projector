require "rails_helper"
require "pp"

RSpec.describe 'boards/new.html.haml', type: :view do
  describe "/new" do
    let(:board) { Board.new }
    
    before(:each) do
      assign(:board, board)
      render
    end

    it "contains has appropriate title" do
      expect(rendered).to have_tag("h4", with: { class: 'card-title'}) do
         with_text "Create board"
      end
    end

    it "contains form with method post" do
      expect(rendered).to have_tag("form", with: { class: "form-group", action: "/boards", method: "post" })
      
    end

    it "contains input for title" do
      expect(rendered).to have_tag("input", with: { name: "board[title]" })
    end

    it "contains input for description" do
      expect(rendered).to have_tag("textarea", with: { name: "board[description]" })
    end

    it "contains radio buttons" do
      expect(rendered).to have_tag("input", count: 2, with: { type: "radio", name: "board[public]" })
    end

    it "contains submit button" do
      expect(rendered).to have_tag("input", with: { type: "submit", value: "Create board" })
    end

  end
end