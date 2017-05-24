require 'rails_helper'

RSpec.describe FavoriteBoard, type: :model do
  describe "validations" do
    describe "user_id" do
      let(:board){ FactoryGirl.create(:board) }
      let(:user){ FactoryGirl.create(:user) }

      subject{ FactoryGirl.build(:favorite_board, user: user, board: board) }

      context "is uniqueness in same board_id" do
        before{ FactoryGirl.create(:favorite_board, user: user) }
        it{ is_expected.to be_valid }
      end

      context "is not uniqueness in same board_id" do
        before{ FactoryGirl.create(:favorite_board, user: user, board: board) }
        it{ is_expected.to_not be_valid }
      end
    end

    describe "board_id" do
      let(:board){ FactoryGirl.create(:board) }
      let(:user){ FactoryGirl.create(:user) }

      subject{ FactoryGirl.build(:favorite_board, user: user, board: board) }

      context "is uniqueness in same board_id" do
        before{ FactoryGirl.create(:favorite_board, board: board) }
        it{ is_expected.to be_valid }
      end

      context "is not uniqueness in same board_id" do
        before{ FactoryGirl.create(:favorite_board, user: user, board: board) }
        it{ is_expected.to_not be_valid }
      end
    end
  end
end
