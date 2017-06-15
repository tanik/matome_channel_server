require 'rails_helper'

RSpec.describe History, type: :model do
  describe "validations" do
    describe "user_id" do
      let(:user){ FactoryGirl.create(:user) }
      let(:board){ FactoryGirl.create(:board) }

      subject{ FactoryGirl.build(:history, user: user, board: board) }

      context "is uniqueness in same board_id" do
        before{ FactoryGirl.create(:history, user: user) }
        it{ is_expected.to be_valid }
      end

      context "is not uniqueness in same board_id" do
        before{ FactoryGirl.create(:history, user: user, board: board) }
        it{ is_expected.to_not be_valid }
      end
    end

    describe "board_id" do
      let(:user){ FactoryGirl.create(:user) }
      let(:board){ FactoryGirl.create(:board) }

      subject{ FactoryGirl.build(:history, user: user, board: board) }

      context "is uniqueness in same user_id" do
        before{ FactoryGirl.create(:history, board: board) }
        it{ is_expected.to be_valid }
      end

      context "is not uniqueness in same user_id" do
        before{ FactoryGirl.create(:history, board: board, user: user) }
        it{ is_expected.to_not be_valid }
      end
    end
  end
end
