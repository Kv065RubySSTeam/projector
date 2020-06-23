require "rails_helper"

RSpec.describe 'cards/_tabs.html.haml', type: :view do
  describe "page content" do
    let!(:card) { create(:card_with_comments, :with_tags) }
    let!(:column) { card.column }
    let!(:board) { column.board }
    let!(:current_user) { card.user }

    before(:each) do
      sign_in current_user
      assign(:card, card)
      assign(:board, board)
      assign(:column, column)
      render partial: "cards/tabs.html.haml", locals: { card: card }
    end

    context 'new card creation history' do
      it 'contains audit' do
        expect(rendered).to have_tag('li', count: 1, with: { class: 'list-group-item' })
      end

      it 'contains correct audit user' do
        expect(rendered).to have_tag('img', with: { class: 'round', src: "/images/placeholder.jpg" })
        expect(rendered).to have_tag('small', with_text: card.audits.last.user.full_name )
      end

      it 'contains correct audit action' do
        expect(rendered).to have_tag('p', with_text: card.audits.last.action.capitalize)
      end

      it 'contains correct audit changes' do
        expect(rendered).to match("#{card.audits.last.audited_changes[0..3]}")
      end
    end
  end
end