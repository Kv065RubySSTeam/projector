require "rails_helper"

RSpec.describe 'boards/show.html.haml', type: :view do
    let!(:user) { create(:user) }
    let!(:membership) { create(:admin_membership, user_id: user.id) }
    let!(:board) { membership.board }
    let!(:columns) { create_list(:column_with_cards, 5) }
    let!(:cards) { Card.all }

    before(:each) do
      sign_in user
      assign(:board, board)
      assign(:column, board.columns.new)
      assign(:columns, columns)
      allow(view).to receive(:current_user).and_return(user)
      render
    end

  describe "/show" do
    describe "board title and description" do
      it "contains board title" do
        expect(rendered).to match("#{board.title}")
      end
      
      it "contains board description" do
        expect(rendered).to match("#{board.description}")
      end
    end

    describe "board buttons for login user" do
      it "contains back button" do
        expect(rendered).to have_tag("a", with: { href: "/boards" }) do
          with_text "Back"
        end
      end

      it "contains edit button" do
        expect(rendered).to have_tag("a", with: { href: "/boards/#{board.id}/edit" }) do
          with_text "Edit"
        end
      end

      it "contains destroy button" do
        expect(rendered).to have_tag("a", with: { href: "/boards/#{board.id}"}) do
          with_text "Destroy"
        end
      end
    end

    describe "crete column button" do
      it "contains add new column button" do
        expect(rendered).to match("Add New Column")
      end
    end

    describe "board columns" do
      it "contains 5 columns" do
        expect(rendered).to have_tag("div", count: columns.length, with: { class: "kanban-board" })
      end

      it "columns have appropriate names" do
        columns.each do |column|
          expect(rendered).to match("#{column.name}")
        end
      end
    end

    describe "board columns cards" do
      it "contains 25 cards" do
        expect(rendered).to have_tag("div", count: cards.length, with: { class: "card-wrapper" })
      end

      it "cards have appropriate titles and bodies" do
        cards.each do |card|
          expect(rendered).to match("#{card.title}")
          expect(rendered).to match("#{card.body.body}")
        end
      end
    end

    describe "membership" do
      it "contains search user form" do
        expect(rendered).to have_tag("input", with: { class: "form-control", name: "find-user"})
      end

      it "contains Remove Admin button" do
        expect(rendered).to have_tag("a", with: { id: "#{user.email}" })
      end

      it "contains member email" do
        expect(rendered).to match("#{user.email}")
      end
    end

  end
end
