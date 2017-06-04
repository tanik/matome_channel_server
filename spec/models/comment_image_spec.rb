require 'rails_helper'

RSpec.describe CommentImage, type: :model do
  describe "validations" do
    describe "comment_id" do
      let(:comment){ FactoryGirl.create(:comment) }
      let(:image){ FactoryGirl.create(:image) }

      subject{ FactoryGirl.build(:comment_image, comment: comment, image: image) }

      context "is uniqueness in same image_id" do
        before{ FactoryGirl.create(:comment_image, comment: comment) }
        it{ is_expected.to be_valid }
      end

      context "is not uniqueness in same image_id" do
        before{ FactoryGirl.create(:comment_image, comment: comment, image: image) }
        it{ is_expected.to_not be_valid }
      end
    end

    describe "image_id" do
      let(:comment){ FactoryGirl.create(:comment) }
      let(:image){ FactoryGirl.create(:image) }

      subject{ FactoryGirl.build(:comment_image, comment: comment, image: image) }

      context "is uniqueness in same comment_id" do
        before{ FactoryGirl.create(:comment_image, image: image) }
        it{ is_expected.to be_valid }
      end

      context "is not uniqueness in same comment_id" do
        before{ FactoryGirl.create(:comment_image, image: image, comment: comment) }
        it{ is_expected.to_not be_valid }
      end
    end
  end

  describe "#to_user_params" do
    let(:comment_image){ FactoryGirl.create(:comment_image) }
    subject{ comment_image.to_user_params }
    it{is_expected.to eq({
      id: comment_image.id,
      comment_id: comment_image.comment_id,
      image: comment_image.image.to_user_params
    })}
  end
end
