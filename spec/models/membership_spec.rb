require 'rails_helper'

RSpec.describe Membership, type: :model do

  let!(:admin_membership) { create(:admin_membership) }
  let(:membership) { create(:membership) }
  let(:ivalid_member) { Membership.new(board: nil, user: nil) } 

  describe 'associations' do
    it { should belong_to(:board) }
    it { should belong_to(:user) }
  end
  
  describe 'indexes' do
    it { should have_db_column(:user_id) }
    it { should have_db_column(:board_id) }
  end
  
  it { should validate_uniqueness_of(:user_id).scoped_to(:board_id) } 

  context 'correct params are passed' do
    it "has a valid factory" do
      expect( build(:admin_membership) ).to be_valid
    end
    it "has valid board_id" do
      expect(admin_membership.board_id).to eq(admin_membership.board.id)
    end
    it "has valid user_id" do
      expect(admin_membership.user_id).to eq(admin_membership.user.id)
    end
    it "new member has default admin value to false" do
      expect(membership.admin).to eq false
    end
  end

  context 'invalid params are passed' do
    it "is not valid without a user && board" do
      expect( ivalid_member ).to_not be_valid
    end
  end
  
  context '#admin!' do
    let(:membership1) { create(:membership) }
    let(:user) { create(:user) }
    subject { membership1.admin! }
    it "expect to return boolean type" do
      expect(admin_membership.admin!).to be_in([true, false])
    end
    it "should mark the membership.admin to true" do
      subject
      expect(admin_membership.reload.admin).to eq(true)
    end
    it "if admin is already true, return true" do
      subject
      admin_membership.admin!
      expect(admin_membership.reload.admin).to eq true
     end
  end

  context '#remove_admin!' do
    subject { admin_membership.remove_admin! }
    it "expect to return boolean type" do
      expect(admin_membership.remove_admin!).to be_in([true, false])
    end
    it 'change admin to false' do
      subject
      expect(admin_membership.reload.admin).to eq false
    end
    it 'if admin is already false, return false' do
      subject
      membership.remove_admin!
      expect(membership.reload.admin).to eq false
    end
  end
end
