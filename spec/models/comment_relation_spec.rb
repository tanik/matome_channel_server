require 'rails_helper'

RSpec.describe CommentRelation, type: :model do

  describe "validations" do
    describe "comment_id" do
      let(:anchor_comment){ FactoryGirl.create(:comment) }
      let(:anchored_comment){ FactoryGirl.create(:comment) }

      subject{ FactoryGirl.build(:comment_relation, comment: anchor_comment, related_comment: anchored_comment) }

      context "is uniqueness in same comment_id" do
        before{ FactoryGirl.create(:comment_relation, comment: anchor_comment) }
        it{ is_expected.to be_valid }
      end

      context "is not uniqueness in same comment_id" do
        before{ FactoryGirl.create(:comment_relation, comment: anchor_comment, related_comment: anchored_comment) }
        it{ is_expected.to_not be_valid }
      end
    end

    describe "related_comment_id" do
      let(:anchor_comment){ FactoryGirl.create(:comment) }
      let(:anchored_comment){ FactoryGirl.create(:comment) }

      subject{ FactoryGirl.build(:comment_relation, comment: anchor_comment, related_comment: anchored_comment) }

      context "is uniqueness in same related_comment_id" do
        before{ FactoryGirl.create(:comment_relation, related_comment: anchored_comment) }
        it{ is_expected.to be_valid }
      end

      context "is not uniqueness in same related_comment_id" do
        before{ FactoryGirl.create(:comment_relation, comment: anchor_comment, related_comment: anchored_comment) }
        it{ is_expected.to_not be_valid }
      end
    end
  end

end
