require 'rails_helper'

RSpec.describe CommentWebsite, type: :model do
  describe "validations" do
    describe "comment_id" do
      let(:comment){ FactoryGirl.create(:comment) }
      let(:website){ FactoryGirl.create(:website) }

      subject{ FactoryGirl.build(:comment_website, comment: comment, website: website) }

      context "is uniqueness in same website_id" do
        before{ FactoryGirl.create(:comment_website, comment: comment) }
        it{ is_expected.to be_valid }
      end

      context "is not uniqueness in same website_id" do
        before{ FactoryGirl.create(:comment_website, comment: comment, website: website) }
        it{ is_expected.to_not be_valid }
      end
    end

    describe "website_id" do
      let(:comment){ FactoryGirl.create(:comment) }
      let(:website){ FactoryGirl.create(:website) }

      subject{ FactoryGirl.build(:comment_website, comment: comment, website: website) }

      context "is uniqueness in same comment_id" do
        before{ FactoryGirl.create(:comment_website, website: website) }
        it{ is_expected.to be_valid }
      end

      context "is not uniqueness in same comment_id" do
        before{ FactoryGirl.create(:comment_website, website: website, comment: comment) }
        it{ is_expected.to_not be_valid }
      end
    end
  end

  describe "#to_user_params" do
    let(:comment_website){ FactoryGirl.create(:comment_website) }
    subject{ comment_website.to_user_params }
    it{is_expected.to eq({
      id: comment_website.id,
      comment_id: comment_website.comment_id,
      website: comment_website.website.to_user_params
    })}
  end
end
