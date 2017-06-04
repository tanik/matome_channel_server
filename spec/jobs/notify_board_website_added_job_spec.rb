require 'rails_helper'

RSpec.describe NotifyBoardWebsiteAddedJob, type: :job do

  let(:website){ FactoryGirl.create(:website, title: title, thumbnail_url: thumbnail_url, full_url: full_url) }
  let(:board_website){ FactoryGirl.create(:board_website, website: website) }
  let(:title){ "Example site" }
  let(:thumbnail_url){ "website/thumbnails/1.png" }
  let(:full_url){ "website/images/1.png" }

  describe "#perform_async" do
    it "matches with enqueued job" do
      expect{ board_website }.to change(NotifyBoardWebsiteAddedJob.jobs, :size).by(1)
    end
  end

  describe "#perform" do
    context "board website exists and website is created" do
      it "board website should be broadcasted" do
        expect(BoardChannel).to receive(:broadcast_to).with(
          board_website.board,
          action: :board_website_added,
          board_website: board_website.to_user_params
        )
        NotifyBoardWebsiteAddedJob.new.perform(board_website.id)
      end
    end
    context "board website exists and website isn't created" do
      before{ allow_any_instance_of(NotifyBoardWebsiteAddedJob).to receive(:sleep).and_return(nil) }
      let(:title){ nil }
      let(:thumbnail_url){ nil }
      let(:full_url){ nil }

      it "board website should be broadcasted" do
        expect(BoardChannel).to_not receive(:broadcast_to)
        expect{ NotifyBoardWebsiteAddedJob.new.perform(board_website.id) }.to raise_error("board website isn't created yet.")
      end
    end

    context "board website doesn't exist" do
      it "board website should not be broadcasted" do
        expect(BoardChannel).to_not receive(:broadcast_to)
        NotifyBoardWebsiteAddedJob.new.perform(0)
      end
    end
  end
end
