require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the UserHelper. For example:
#
# describe UserHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe UsersHelper, type: :helper do
  let!(:user) { build_stubbed :user }

  describe '#get_avatar' do
    subject { helper.get_avatar(user) }

    it { is_expected.to eq('/images/placeholder.jpg') }
  end

  describe '#get_full_user_name' do
    subject { helper.get_full_user_name(user) }

    it { is_expected.to eq(user.full_name) }
  end
end
