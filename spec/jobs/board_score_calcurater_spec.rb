require 'rails_helper'

RSpec.describe BoardScoreCalculater, type: :job do


  describe "#perform_async" do
    it "matches with enqueued job" do
      expect{ BoardScoreCalculater.perform_async }.to change(BoardScoreCalculater.jobs, :size).by(1)
    end
  end

  describe "#perform" do
    it "should receive index_document" do
      FactoryGirl.create(:board)
      expect_any_instance_of(Board).to receive(:update_score).and_call_original
      BoardScoreCalculater.new.perform
    end
  end
end
