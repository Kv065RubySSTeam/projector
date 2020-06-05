require 'rails_helper'

RSpec.describe 'boards/_users', type: :view do

  let!(:user) {create(:user) }
  let!(:user2) {create(:user) }
  let!(:board) { create(:board, user: user) }
  let!(:admin_member) { create(:admin_membership, board: board, user_id: user.id) }
  let!(:member2) { create(:membership, board: board, user: user2) }
  
  before do
    sign_in user
    assign(:board, board)
    allow(view).to receive(:current_user).and_return(user)
    render partial: "memberships/index.html.haml", locals: { member: member2 }
  end

  describe 'main index page elements' do
    it 'has wrapper for members' do
      subject
      expect(rendered).to have_tag('#user-section') 
    end
    it 'has title text' do
      expect(rendered).to have_tag('h3.pl-2', text: /Members/)
    end

    context "hident input" do
      it 'has createor name' do
        expect(rendered).to have_tag('input#creator', value: /#{board.user.email}/)
      end
      it "has hidden type" do
        expect(rendered).to have_tag('input#creator', type: "hidden")
      end
      it "has id creato" do
        expect(rendered).to have_tag('input', id: "creator")
      end
    end

    context "memberships section wrapper" do
      it "has section tag" do
        expect(rendered).to have_tag('section') 
      end
      it "has render correct number of memberships" do
        expect(rendered).to have_tag("section div",
                                      count: board.memberships.length,
                                      with: { class: "mb-2" } )
      end
      it "has appropriate email" do
        board.memberships.each do |member|
          expect(rendered).to match("#{member.user.email}")
        end
      end
    end

    context "for user as a membership" do
      it 'has Add Admin button' do
        expect(response).to have_tag('a.btn-sm', text: /Add Admin/)
      end
      it "has valid href to change rights" do
        expect(response).to have_tag("a.btn-sm",
                                    href: "#{board.id}/memberships/#{member2.id}/admin")
      end
      it "has submit AJAX request" do
        expect(response).to have_tag("a[data-remote=true]")
      end
      it "has data transfer method put" do
        expect(response).to have_tag("a[data-method=put]")
      end
      it "has javascrript method to handle the click" do
        expect(response).to have_tag("a[onclick='changeRights(event)']")
      end
      it "has id with user email" do
        expect(response).to have_tag("a", id: member2.user.email)
      end
    end

  end
end
