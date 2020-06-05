require 'rails_helper'

RSpec.describe 'boards/_users', type: :view do
  
  let!(:user) {create(:user) }
  let!(:board) { create(:board, user: user) }
  let!(:admin_member) { create(:admin_membership, board: board, user_id: user.id) }
  
  before do
    sign_in user
    assign(:board, board)
    allow(view).to receive(:current_user).and_return(user)
    render partial: "memberships/membership.html.haml", locals: { member: admin_member }
  end

  describe 'main memberships elements' do
    context "for user as an admin" do
      it 'has a wrapper for each memebership' do
        expect(response).to have_tag('div.mb-2')
      end
      it 'has Remove Admin button' do
        expect(response).to have_tag('a.btn-sm', text: /Remove Admin/)
      end
      it 'has admin email' do
        expect(response).to have_tag('span', text: /#{admin_member.user.email}/)
      end
      it 'has star icon to show as user is admin' do
        expect(response).to have_tag('i.bx-star.bxs-star')
      end
       it "has valid href to remove admin rights" do
          expect(response).to have_tag("a.btn-sm",
                                      href: "#{board.id}/memberships/#{admin_member.id}/admin")
      end
      it "has submit AJAX request" do
        expect(response).to have_tag("a[data-remote=true]")
      end
      it "has data transfer method put" do
        expect(response).to have_tag("a[data-method=put]")
      end
    end
  end
end
