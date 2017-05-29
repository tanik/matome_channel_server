require 'rails_helper'

RSpec.describe NotifyCommentImageAddedJob, type: :job do

  let(:image){ FactoryGirl.create(:image, thumbnail_url: thumbnail_url, full_url: full_url) }
  let(:comment_image){ FactoryGirl.create(:comment_image, image: image) }
  let(:thumbnail_url){ "images/thumbnails/1.png" }
  let(:full_url){ "images/images/1.png" }

  describe "#perform_async" do
    it "matches with enqueued job" do
      expect{ comment_image }.to change(NotifyCommentImageAddedJob.jobs, :size).by(1)
    end
  end

  describe "#perform" do
    context "comment image exists and image is created" do
      it "comment image should be broadcasted" do
        expect(BoardChannel).to receive(:broadcast_to).with(
          comment_image.comment.board,
          action: :comment_image_added,
          comment_image: comment_image.to_user_params
        )
        NotifyCommentImageAddedJob.new.perform(comment_image.id)
      end
    end
    context "comment image exists and image isn't created" do
      before{ allow_any_instance_of(NotifyCommentImageAddedJob).to receive(:sleep).and_return(nil) }
      let(:thumbnail_url){ nil }
      let(:full_url){ nil }

      it "comment image should be broadcasted" do
        expect(BoardChannel).to_not receive(:broadcast_to)
        expect{ NotifyCommentImageAddedJob.new.perform(comment_image.id) }.to raise_error("comment image isn't created yet.")
      end
    end

    context "comment image doesn't exist" do
      it "comment image should not be broadcasted" do
        expect(BoardChannel).to_not receive(:broadcast_to)
        NotifyCommentImageAddedJob.new.perform(0)
      end
    end
  end
end
