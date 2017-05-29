require 'rails_helper'

RSpec.describe CommentParser, type: :job do
  let(:comment){ FactoryGirl.create(:comment, content: content) }
  let(:content) do
    <<-EOS
    test
    #{url}
    EOS
  end
  let(:url){ "http://example.com/test" }
  let(:status){ 200 }
  let(:response_headers){ {'Content-Type' => 'image/png'} }

  before do
    stub_request(:head, url).to_return({
      status: status, headers: response_headers
    })
  end

  describe "#perform_async" do
    it "matches with enqueued job" do
      expect{ comment }.to change(CommentParser.jobs, :size).by(1)
    end
  end

  describe "#perform" do
    context "comment exists and image url included" do
      let(:status){ 200 }
      let(:response_headers){ {'Content-Type' => 'image/png'} }
      it do
        expect{ CommentParser.new.perform(comment.id) }.
          to change(Image, :count).by(1)
      end
    end
    context "comment exists and website url included" do
      let(:status){ 200 }
      let(:response_headers){ {'Content-Type' => 'text/html'} }
      it do
        expect{ CommentParser.new.perform(comment.id) }.
          to change(Website, :count).by(1)
      end
    end
    context "comment exists and website url included" do
      let(:status){ 404 }
      let(:response_headers){ {'Content-Type' => 'text/html'} }
      it do
        expect{ CommentParser.new.perform(comment.id) }.
          to raise_error(RestClient::NotFound)
      end
    end
    context "comment doesn't exist" do
      it "comment should not be broadcasted" do
        expect(URI).to_not receive(:extract)
        CommentParser.new.perform(0)
      end
    end
  end
end
