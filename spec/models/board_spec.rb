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

  describe "#thumbnail_url" do
    let(:board){ FactoryGirl.create :board }

    subject{ board.thumbnail_url }

    context "board has no image" do
      it{ is_expected.to eq("#{ENV["AWS_S3_ENDPOINT"]}statics/placeholder.png") }
    end
    context "board has only image" do
      let(:board_image){ FactoryGirl.create :board_image, board: board }
      before{ board_image }
      it{ is_expected.to eq(board_image.image.thumbnail) }
    end
    context "board has only website" do
      let(:board_website){ FactoryGirl.create :board_website, board: board }
      before{ board_website }
      it{ is_expected.to eq(board_website.website.thumbnail) }
    end
    context "board has image and website" do
      let(:image){ FactoryGirl.create :image, created_at: 1.days.ago }
      let(:website){ FactoryGirl.create :website, created_at: 2.days.ago }
      let(:board_image){ FactoryGirl.create :board_image, board: board, image: image }
      let(:board_website){ FactoryGirl.create :board_website, board: board, website: website }

      before do
        board_image
        board_website
      end

      it{ is_expected.to eq(image.thumbnail) }
    end
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
    let(:favorite_board){ FactoryGirl.create :favorite_board, board: board }

    before{ favorite_board }

    subject{ board.to_show_params }

    it{ is_expected.to eq ({
      id: board.id,
      title: board.title,
      score: board.score,
      res_count: board.res_count,
      fav_count: board.fav_count,
      first_comment: board.first_comment,
      thumbnail_url: board.thumbnail_url,
      favorite_user_ids: [favorite_board.user_id],
      category_tree: board.category.tree,
      websites: board.board_websites.includes(:website).limit(20).map(&:to_user_params),
      images: board.board_images.includes(:image).limit(20).map(&:to_user_params),
      comments: board.comments.order(id: :desc).map(&:to_user_params)})
    }
  end
end
