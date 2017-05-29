require 'rails_helper'

RSpec.describe NotifyCommentFavoritedJob, type: :job do

  describe "#perform_async" do
    let(:favorite_comment){ FactoryGirl.create(:favorite_comment) }
    it "matches with enqueued job" do
      expect{ favorite_comment }.to change(NotifyCommentFavoritedJob.jobs, :size).by(1)
    end
  end

  describe "#perform" do
    context "comment exists" do
      let(:favorite_comment){ FactoryGirl.create(:favorite_comment) }
      it "comment should be broadcasted" do
        expect(BoardChannel).to receive(:broadcast_to).with(
          favorite_comment.comment.board,
          action: :comment_favorited,
          favorite: favorite_comment
        )
        NotifyCommentFavoritedJob.new.perform(favorite_comment.id)
      end
    end

    context "comment doesn't exist" do
      it "comment should not be broadcasted" do
        expect(BoardChannel).to_not receive(:broadcast_to)
        NotifyCommentFavoritedJob.new.perform(0)
      end
    end
  end
end
