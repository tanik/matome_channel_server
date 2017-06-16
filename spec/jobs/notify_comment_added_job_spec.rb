require 'rails_helper'

RSpec.describe NotifyCommentAddedJob, type: :job do
  describe "#perform_async" do
    let(:comment){ FactoryGirl.create(:comment) }
    it "matches with enqueued job" do
      expect{ comment }.to change(NotifyCommentAddedJob.jobs, :size).by(1)
    end
  end

  describe "#perform" do
    context "comment exists" do
      let(:comment){ FactoryGirl.create(:comment) }
      it "comment should be broadcasted" do
        expect(BoardChannel).to receive(:broadcast_to).with(
          comment.board,
          action: :comment_added,
          comment: comment.to_user_params_with_board
        )
        NotifyCommentAddedJob.new.perform(comment.id)
      end
    end

    context "comment doesn't exist" do
      it "comment should not be broadcasted" do
        expect(BoardChannel).to_not receive(:broadcast_to)
        NotifyCommentAddedJob.new.perform(0)
      end
    end
  end
end
