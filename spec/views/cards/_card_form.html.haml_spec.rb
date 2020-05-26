require "rails_helper"

RSpec.describe 'cards/_card_form.html.haml', type: :view do
  describe "page content" do
    let!(:column) { create(:column) }
    let!(:board) { column.board }
    let!(:card) { create(:card) }

    before do
      assign(:column, column)
      assign(:card, card)
      render
    end

    it 'contains form group' do
      expect(rendered).to have_tag('form', with: { class: 'form-group', action: "/boards/#{board.id}/columns/#{column.id}/cards", method: 'post' })
    end

    it "contains button" do
      expect(rendered).to have_tag('button', with: { id: 'CancelBtn' })
    end
  end
end
