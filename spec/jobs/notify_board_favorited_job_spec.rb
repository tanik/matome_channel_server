require 'rails_helper'

RSpec.describe NotifyBoardFavoritedJob, type: :job do

  describe "#perform_async" do
    let(:favorite_board){ FactoryGirl.create(:favorite_board) }
    it "matches with enqueued job" do
      expect{ favorite_board }.to change(NotifyBoardFavoritedJob.jobs, :size).by(1)
    end
  end

  describe "#perform" do
    context "comment exists" do
      let(:favorite_board){ FactoryGirl.create(:favorite_board) }
      it "comment should be broadcasted" do
        expect(BoardChannel).to receive(:broadcast_to).with(
          favorite_board.board,
          action: :board_favorited,
          favorite: favorite_board
        )
        NotifyBoardFavoritedJob.new.perform(favorite_board.id)
      end
    end

    context "comment doesn't exist" do
      it "comment should not be broadcasted" do
        expect(BoardChannel).to_not receive(:broadcast_to)
        NotifyBoardFavoritedJob.new.perform(0)
      end
    end
  end
end
