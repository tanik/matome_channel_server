require 'rails_helper'

RSpec.describe BoardIndexer, type: :job do

  let(:board){ FactoryGirl.create(:board) }

  describe "#perform_async" do
    it "matches with enqueued job" do
      expect{ board }.to change(BoardIndexer.jobs, :size).by(1)
    end
  end

  describe "#perform" do
    context "when operation is create" do
      it "should receive index_document" do
        expect_any_instance_of(Elasticsearch::Model::Proxy::InstanceMethodsProxy).to receive(:index_document)
        BoardIndexer.new.perform('create', board.id)
      end
    end
    context "when operation is update" do
      it "should receive update_document" do
        expect_any_instance_of(Elasticsearch::Model::Proxy::InstanceMethodsProxy).to receive(:update_document)
        BoardIndexer.new.perform('update', board.id)
      end
    end
    context "when operation is invalid" do
      it "should receive index_document" do
        expect{ BoardIndexer.new.perform('invalid', board.id) }.to raise_error(ArgumentError, "Unknown operation 'invalid'")
      end
    end
    context "board doesn't exist" do
      it "should not index" do
        BoardIndexer.new.perform('create', 0)
      end
    end
  end
end
