require 'rails_helper'

RSpec.describe 'columns/_column', type: :view do
  before do
    sign_in user

    assign(:board, board)
    render partial: "columns/column.html.haml",  locals: { column: column }
  end

  shared_examples "badge" do
    it 'has correct class' do
      expect(rendered).to have_tag('.badge')
    end

    it 'has correct cards number' do 
      expect(rendered).to match(column.cards.count.to_s)
    end
  end

  shared_examples "column wrappers" do
    it 'has correct class and data attribute' do
      expect(rendered).to have_tag("div", with: { class: "kanban-board",
        'data-column-id' => column.id.to_s })
    end

    it "has correct header class" do 
      expect(rendered).to have_tag("header.kanban-board-header")
    end
  end

  shared_examples "column cards" do
    it "has cards class" do
      expect(rendered).to have_tag('main.kanban-drag')
    end

    it "render cards inside column with correct data" do
      column.cards.each do |card|
        expect(rendered).to have_tag("div", with: { class: "kanban-item", 
          "data-card-id" => card.id,
          "data-position" => card.position })
      end
    end

    it "render correct number of cards" do
      expect(column.cards.count).to eq(rendered.scan("card-wrapper").length)
    end
  end

  shared_examples "column title" do 
    it 'has correct title' do
      expect(rendered).to match(column.name)
    end
  end

  context "with permission" do
    let!(:membership) { create(:membership) }
    let!(:board) { membership.board }
    let!(:user) { membership.user }
    let!(:column) { create(:column_with_cards, board: board, user: user) }

    it_behaves_like "badge"
    it_behaves_like "column wrappers"
    it_behaves_like "column cards"
    it_behaves_like "column title"
    
    it 'has new card link' do
      expect(rendered).to have_tag("a", with: { id: "add-card", class: "kanban-title-button btn",
        href: "/boards/#{board.id}/columns/#{column.id}/cards/new" }) do
        with_text "+ Add New Item"
      end
    end

    it 'can edit column title' do
      expect(rendered).to have_tag('.kanban-title-board[contenteditable="true"]')
    end

    context "dropdown" do
      it 'has dropdown class' do
        expect(rendered).to have_tag('.dropdown')
      end
  
      it 'has dropdown button classes with correct attributes' do
        expect(rendered).to have_tag("div", with: { id: "dropdownMenuButton", class: "dropdown-toggle",
          role: "button", "data-toggle" => "dropdown"})
      end
  
      it 'has dropdown menu with correct attribute' do
        expect(rendered).to have_tag("div", with: { class: "dropdown-menu",
          "aria-labelledby" => "dropdownMenuButton"})
      end
  
      it 'has correct delete column link' do
        expect(rendered).to have_tag("a", with: { class: "kanban-delete dropdown-item",
          href: "/boards/#{board.id}/columns/#{column.id}",
          "data-remote" => "true",
          "data-method" => "delete"})
  
        expect(rendered).to match('Delete')
      end
    end
  end

  context "without permission" do
    let!(:user) { create(:user) }
    let!(:board) { create(:board) }
    let!(:column) {create(:column_with_cards)}

    it_behaves_like "badge"
    it_behaves_like "column wrappers"
    it_behaves_like "column cards"
    it_behaves_like "column title"

    it 'doesn\'t have card link' do
      expect(rendered).not_to have_tag("a", with: { id: "add-card", class: "kanban-title-button btn",
        href: "/boards/#{board.id}/columns/#{column.id}/cards/new" }) do
        with_text "+ Add New Item"
      end
    end

    it 'can\'t edit column title' do
      expect(rendered).to have_tag('.kanban-title[contenteditable="false"]')
    end

    it 'doesn\'t have dropdown class' do
      expect(rendered).not_to have_tag('.dropdown')
    end
  end
end
