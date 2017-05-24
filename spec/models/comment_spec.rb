require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe "validations" do
    describe "name" do

      subject{ FactoryGirl.build(:comment, name: name) }

      context "is valid" do
        let(:name){ "test name" }
        it{ is_expected.to be_valid }
      end

      context "is too long" do
        let(:name){ "a"*256 }
        it{ is_expected.to_not be_valid }
      end
    end

    describe "content" do

      subject{ FactoryGirl.build(:comment, content: content) }

      context "is valid" do
        let(:content){ "test content" }
        it{ is_expected.to be_valid }
      end

      context "is too long" do
        let(:content){ "a"*2049 }
        it{ is_expected.to_not be_valid }
      end

      context "is too short" do
        let(:content){ "" }
        it{ is_expected.to_not be_valid }
      end
    end
  end

  describe "#to_user_params" do
    let(:favorite_comments){ FactoryGirl.create_list(:favorite_comment, 3, comment: comment) }
    let(:comment){ FactoryGirl.create(:comment) }

    before{ favorite_comments }

    subject{ comment.to_user_params }

    it{ is_expected.to eq({
      id:         comment.id,
      user_id:    comment.user_id,
      board_id:   comment.board_id,
      num:        comment.num,
      name:       comment.name,
      content:    comment.content,
      created_at: comment.created_at,
      hash_id:    comment.hash_id,
      favorite_user_ids: favorite_comments.map(&:user_id),
    })
    }
  end
end
