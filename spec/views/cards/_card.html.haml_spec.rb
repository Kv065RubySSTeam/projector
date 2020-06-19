require "rails_helper"

RSpec.describe 'cards/_card.html.haml', type: :view do
  describe "page content" do
    let!(:card) { create(:card) }
    let!(:user) { card.user }

    before do
      assign(:card, card)
      render partial: "cards/card.html.haml", locals: {card: card}
    end

    it 'contains title' do
      expect(rendered).to have_tag('div', with: { class: 'kanban-item' })
    end

    it "contains correct title" do
      expect(rendered).to match("#{card.title}")
    end


    it "contains correct body" do
      expect(rendered).to match("#{card.body}")
    end

    context "with assignee" do
      it "contains assigned user on card" do
        expect(rendered).to have_tag('div', with: { class: 'kanban-users' }) do
          expect(rendered).to have_tag('img', with: { class: 'rounded', src: "/images/placeholder.jpg" })
        end
      end
    end
  end

  context "without assignee" do
    let!(:card) { create(:card) }
    before do
      assign(:card, card)
      card.remove_assign!
      render partial: "cards/card.html.haml", locals: {card: card}
    end 
    it "contains no assignees on card" do
      expect(rendered).not_to have_tag('img', with: { class: 'rounded', src: "/images/placeholder.jpg" })
    end
  end
end
