require 'rails_helper'

RSpec.describe BoardImage, type: :model do
  describe "validations" do
    describe "board_id" do
      let(:board){ FactoryGirl.create(:board) }
      let(:image){ FactoryGirl.create(:image) }

      subject{ FactoryGirl.build(:board_image, board: board, image: image) }

      context "is uniqueness in same image_id" do
        before{ FactoryGirl.create(:board_image, board: board) }
        it{ is_expected.to be_valid }
      end

      context "is not uniqueness in same image_id" do
        before{ FactoryGirl.create(:board_image, board: board, image: image) }
        it{ is_expected.to_not be_valid }
      end
    end

    describe "image_id" do
      let(:board){ FactoryGirl.create(:board) }
      let(:image){ FactoryGirl.create(:image) }

      subject{ FactoryGirl.build(:board_image, board: board, image: image) }

      context "is uniqueness in same board_id" do
        before{ FactoryGirl.create(:board_image, image: image) }
        it{ is_expected.to be_valid }
      end

      context "is not uniqueness in same board_id" do
        before{ FactoryGirl.create(:board_image, image: image, board: board) }
        it{ is_expected.to_not be_valid }
      end
    end
  end

  describe "#to_user_params" do
    let(:board_image){ FactoryGirl.create(:board_image) }
    subject{ board_image.to_user_params }
    it{is_expected.to eq({
      id: board_image.id,
      board_id: board_image.board_id,
      image: board_image.image.to_user_params
    })}
  end
end
