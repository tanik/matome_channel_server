require 'rails_helper'

RSpec.describe NotifyCommentWebsiteAddedJob, type: :job do

  let(:website){ FactoryGirl.create(:website, title: title, thumbnail_url: thumbnail_url, full_url: full_url) }
  let(:comment_website){ FactoryGirl.create(:comment_website, website: website) }
  let(:title){ "Example site" }
  let(:thumbnail_url){ "website/thumbnails/1.png" }
  let(:full_url){ "website/images/1.png" }

  describe "#perform_async" do
    it "matches with enqueued job" do
      expect{ comment_website }.to change(NotifyCommentWebsiteAddedJob.jobs, :size).by(1)
    end
  end

  describe "#perform" do
    context "comment website exists and website is created" do
      it "comment website should be broadcasted" do
        expect(BoardChannel).to receive(:broadcast_to).with(
          comment_website.comment.board,
          action: :comment_website_added,
          comment_website: comment_website.to_user_params
        )
        NotifyCommentWebsiteAddedJob.new.perform(comment_website.id)
      end
    end
    context "comment website exists and website isn't created" do
      before{ allow_any_instance_of(NotifyCommentWebsiteAddedJob).to receive(:sleep).and_return(nil) }
      let(:title){ nil }
      let(:thumbnail_url){ nil }
      let(:full_url){ nil }

      it "comment website should be broadcasted" do
        expect(BoardChannel).to_not receive(:broadcast_to)
        expect{ NotifyCommentWebsiteAddedJob.new.perform(comment_website.id) }.to raise_error("comment website isn't created yet.")
      end
    end

    context "comment website doesn't exist" do
      it "comment website should not be broadcasted" do
        expect(BoardChannel).to_not receive(:broadcast_to)
        NotifyCommentWebsiteAddedJob.new.perform(0)
      end
    end
  end
end
