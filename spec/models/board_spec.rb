require 'rails_helper'

RSpec.describe Board, type: :model do

  describe "validations" do
    describe "title" do

      subject{ FactoryGirl.build(:board, title: title) }

      context "is valid" do
        let(:title){ "test title" }
        it{ is_expected.to be_valid }
      end

      context "is too long" do
        let(:title){ "a"*256 }
        it{ is_expected.to_not be_valid }
      end

      context "is too short" do
        let(:title){ "" }
        it{ is_expected.to_not be_valid }
      end
    end
  end

  describe "#first_comment" do
    let(:board){ FactoryGirl.create :board, :with_comments }

    subject{ board.first_comment }

    it{ is_expected.to eq board.comments.first.content }
  end

  describe "#fav_count" do
    let(:favorite_boards){ FactoryGirl.create_list :favorite_board, 3, board: board }
    let(:board){ FactoryGirl.create :board, :with_comments }

    before{ favorite_boards }
    subject{ board.fav_count }

    it{ is_expected.to eq (favorite_boards.count) }
  end

  describe "#to_index_params" do
    let(:board){ FactoryGirl.create :board, :with_comments }

    subject{ board.to_index_params }

    it{ is_expected.to eq ({
      id: board.id,
      title: board.title,
      score: board.score,
      res_count: board.res_count,
      fav_count: board.fav_count,
      first_comment: board.first_comment,
      thumbnail_url: board.thumbnail_url})
    }
  end

  describe "#to_show_params" do
    let(:board){ FactoryGirl.create :board, :with_comments }

    subject{ board.to_show_params }

    it{ is_expected.to eq ({
      id: board.id,
      title: board.title,
      score: board.score,
      res_count: board.res_count,
      fav_count: board.fav_count,
      first_comment: board.first_comment,
      thumbnail_url: board.thumbnail_url,
      comments: board.comments.order(id: :desc).map(&:to_user_params)})
    }
  end
end
