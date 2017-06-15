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

  describe ".popular" do

    let(:time){ 1.hours.ago }
    let(:limit){ 10 }

    subject{ Comment.popular time, limit, category_ids  }

    context "when category_id doesn't exist" do
      let(:category_ids){ [] }
      let(:comment1){ FactoryGirl.create(:comment) }
      let(:comment2){ FactoryGirl.create(:comment) }
      let(:comment3){ FactoryGirl.create(:comment) }
      let(:comment4){ FactoryGirl.create(:comment) }
      let(:comment5){ FactoryGirl.create(:comment) }
      let(:comment6){ FactoryGirl.create(:comment) }
      before do
        # comment1 -> fav 5 + rep 5 = 10
        FactoryGirl.create_list(:favorite_comment, 5, comment: comment1, )
        FactoryGirl.create_list(:comment_relation, 5, related_comment: comment1)
        # comment2 -> fav 6 + rep 3 =  9
        FactoryGirl.create_list(:favorite_comment, 6, comment: comment2)
        FactoryGirl.create_list(:comment_relation, 3, related_comment: comment2)
        # comment3 -> fav 0 + rep 8 =  8
        FactoryGirl.create_list(:comment_relation, 8, related_comment: comment3)
        # comment4 -> fav 7 + rep 0 =  7
        FactoryGirl.create_list(:favorite_comment, 7, comment: comment4)
        # comment5 -> fav 0 + rep 0 =  0
        # comment6 -> so old fav 10 + so old rep 10 = 0
        FactoryGirl.create_list(:favorite_comment, 10, comment: comment6, created_at: time.ago(1.hours))
        FactoryGirl.create_list(:comment_relation, 10, related_comment: comment6, created_at: time.ago(1.hours))
      end

      it{ is_expected.to eq([comment1,comment2,comment3,comment4])}

      context 'and over limit' do
        let(:limit){ 2 }
        it{ is_expected.to eq([comment1,comment2])}
      end
    end

    context "when category_ids exists" do
      let(:root_category){ FactoryGirl.create(:category, :root) }
      let(:child_category){ FactoryGirl.create(:category, parent: root_category) }
      let(:root_category_board){ FactoryGirl.create(:board, category: root_category) }
      let(:child_category_board){ FactoryGirl.create(:board, category: child_category) }
      let(:unmatch_category_board){ FactoryGirl.create(:board) }
      let(:root_category_comment){ FactoryGirl.create(:comment, board: root_category_board) }
      let(:child_category_comment){ FactoryGirl.create(:comment, board: child_category_board) }
      let(:unmatch_category_comment){ FactoryGirl.create(:comment, board: unmatch_category_board) }
      let(:category_ids){ [root_category.id, child_category.id] }

      before do
        # root_category_comment    -> fav 5 + rep 5 = 10
        FactoryGirl.create_list(:favorite_comment, 5, comment: root_category_comment)
        FactoryGirl.create_list(:comment_relation, 5, related_comment: root_category_comment)
        # child_category_comment   -> fav 3 + rep 3 = 6
        FactoryGirl.create_list(:favorite_comment, 3, comment: child_category_comment)
        FactoryGirl.create_list(:comment_relation, 3, related_comment: child_category_comment)
        # unmatch_category_comment -> unmatch category = 0
        FactoryGirl.create_list(:favorite_comment, 1, comment: unmatch_category_comment)
        FactoryGirl.create_list(:comment_relation, 1, related_comment: unmatch_category_comment)
      end

      it{ is_expected.to eq([root_category_comment, child_category_comment])}
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
      images:     comment.images.map(&:to_user_params),
      websites:   comment.websites.map(&:to_user_params),
      favorite_user_ids: favorite_comments.map(&:user_id),
    })
    }
  end

  describe "#all_related_comments" do
    let(:comment){ FactoryGirl.create(:comment) }
    let(:anchor_comment){ FactoryGirl.create(:comment_relation, comment: comment).related_comment }
    let(:anchored_comment){ FactoryGirl.create(:comment_relation, related_comment: comment).comment }

    before do
      anchor_comment
      anchored_comment
    end

    subject{ comment.all_related_comments }

    it{ is_expected.to eq([anchored_comment, anchor_comment]) }
  end
end
