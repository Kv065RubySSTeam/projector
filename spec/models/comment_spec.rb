require 'rails_helper'

RSpec.describe Comment, type: :model do
 
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:card) }
  end

  describe 'validations' do
    subject { comment.valid? }
    let(:comment) { create(:comment) }

    context "valid length" do   
      it "has no errors" do
        expect(subject).to be true
      end
    end

    context "invalid length" do
      before do
        comment.body = "b" * 1001
      end

      it "has related errors" do
        expect(subject).to be false
        expect(comment.errors.to_a).to eq(["Body is too long (maximum is 1000 characters)"])
      end

      it "has blank body" do
        comment.body = nil
        expect(subject).to be false
        expect(comment.errors.to_a).to eq(["Body can't be blank"])
      end
    end
  end
end
