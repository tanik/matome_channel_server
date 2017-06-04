require 'rails_helper'

RSpec.describe BoardWebsite, type: :model do
  describe "validations" do
    describe "board_id" do
      let(:board){ FactoryGirl.create(:board) }
      let(:website){ FactoryGirl.create(:website) }

      subject{ FactoryGirl.build(:board_website, board: board, website: website) }

      context "is uniqueness in same website_id" do
        before{ FactoryGirl.create(:board_website, board: board) }
        it{ is_expected.to be_valid }
      end

      context "is not uniqueness in same website_id" do
        before{ FactoryGirl.create(:board_website, board: board, website: website) }
        it{ is_expected.to_not be_valid }
      end
    end

    describe "website_id" do
      let(:board){ FactoryGirl.create(:board) }
      let(:website){ FactoryGirl.create(:website) }

      subject{ FactoryGirl.build(:board_website, board: board, website: website) }

      context "is uniqueness in same board_id" do
        before{ FactoryGirl.create(:board_website, website: website) }
        it{ is_expected.to be_valid }
      end

      context "is not uniqueness in same board_id" do
        before{ FactoryGirl.create(:board_website, website: website, board: board) }
        it{ is_expected.to_not be_valid }
      end
    end
  end

  describe "#to_user_params" do
    let(:board_website){ FactoryGirl.create(:board_website) }
    subject{ board_website.to_user_params }
    it{is_expected.to eq({
      id: board_website.id,
      board_id: board_website.board_id,
      website: board_website.website.to_user_params
    })}
  end
end
