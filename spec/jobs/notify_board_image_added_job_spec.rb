require 'rails_helper'

RSpec.describe NotifyBoardImageAddedJob, type: :job do

  let(:image){ FactoryGirl.create(:image, thumbnail_url: thumbnail_url, full_url: full_url) }
  let(:board_image){ FactoryGirl.create(:board_image, image: image) }
  let(:thumbnail_url){ "images/thumbnails/1.png" }
  let(:full_url){ "images/images/1.png" }

  describe "#perform_async" do
    it "matches with enqueued job" do
      expect{ board_image }.to change(NotifyBoardImageAddedJob.jobs, :size).by(1)
    end
  end

  describe "#perform" do
    context "board image exists and image is created" do
      it "board image should be broadcasted" do
        expect(BoardChannel).to receive(:broadcast_to).with(
          board_image.board,
          action: :board_image_added,
          board_image: board_image.to_user_params
        )
        NotifyBoardImageAddedJob.new.perform(board_image.id)
      end
    end
    context "board image exists and image isn't created" do
      before{ allow_any_instance_of(NotifyBoardImageAddedJob).to receive(:sleep).and_return(nil) }
      let(:thumbnail_url){ nil }
      let(:full_url){ nil }

      it "board image should be broadcasted" do
        expect(BoardChannel).to_not receive(:broadcast_to)
        expect{ NotifyBoardImageAddedJob.new.perform(board_image.id) }.to raise_error("board image isn't created yet.")
      end
    end

    context "board image doesn't exist" do
      it "board image should not be broadcasted" do
        expect(BoardChannel).to_not receive(:broadcast_to)
        NotifyBoardImageAddedJob.new.perform(0)
      end
    end
  end
end
