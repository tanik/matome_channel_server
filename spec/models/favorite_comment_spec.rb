require 'rails_helper'

RSpec.describe FavoriteComment, type: :model do
  describe "validations" do
    describe "user_id" do
      let(:comment){ FactoryGirl.create(:comment) }
      let(:user){ FactoryGirl.create(:user) }

      subject{ FactoryGirl.build(:favorite_comment, user: user, comment: comment) }

      context "is uniqueness in same comment_id" do
        before{ FactoryGirl.create(:favorite_comment, user: user) }
        it{ is_expected.to be_valid }
      end

      context "is not uniqueness in same comment_id" do
        before{ FactoryGirl.create(:favorite_comment, user: user, comment: comment) }
        it{ is_expected.to_not be_valid }
      end
    end

    describe "comment_id" do
      let(:comment){ FactoryGirl.create(:comment) }
      let(:user){ FactoryGirl.create(:user) }

      subject{ FactoryGirl.build(:favorite_comment, user: user, comment: comment) }

      context "is uniqueness in same comment_id" do
        before{ FactoryGirl.create(:favorite_comment, comment: comment) }
        it{ is_expected.to be_valid }
      end

      context "is not uniqueness in same comment_id" do
        before{ FactoryGirl.create(:favorite_comment, user: user, comment: comment) }
        it{ is_expected.to_not be_valid }
      end
    end
  end

end
