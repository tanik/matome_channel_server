require 'rails_helper'

RSpec.describe WebshotCreatorJob, type: :job do
  let(:website){ FactoryGirl.create(:website, title: nil, thumbnail_url: nil, full_url: nil) }
  let(:resp_hash){ {state: 'success', title: 'Example', thumbnail: 'images/thumbnails/1.png', image: 'images/images/1.png'} }
  let(:response){ resp_hash.to_json }
  let(:status){ 200 }
  before do
    stub_request(:post, "#{ENV['API_GATEWAY_ENDPOINT']}/webshots").with({
      body: {id: website.id, url: website.original_url}.to_json
    }).to_return({
      status: status,
      body: response
    })
  end

  describe "#perform_async" do
    it "matches with enqueued job" do
      expect{ website.send(:create_webshot) }.to change(WebshotCreatorJob.jobs, :size).by(1)
    end
  end

  describe "#perform" do
    context "website exists and api result is success" do
      it "should be updated" do
        expect{ WebshotCreatorJob.new.perform(website.id) }.
          to change{ website.reload.title }.to(resp_hash[:title])
      end
      it "should be updated" do
        expect{ WebshotCreatorJob.new.perform(website.id) }.
          to change{ website.reload.thumbnail_url }.to(resp_hash[:thumbnail])
      end
      it "should be updated" do
        expect{ WebshotCreatorJob.new.perform(website.id) }.
          to change{ website.reload.full_url }.to(resp_hash[:image])
      end
    end

    context "comment image exists and api result is failure" do
      let(:resp_hash){ {state: 'failure', message: "something wrong"} }
      it "should request to api gateway" do
        expect{ WebshotCreatorJob.new.perform(website.id) }.
          to raise_error("something wrong")
      end
    end

    context "comment image exists and http status is failed" do
      let(:status){ 404 }
      it "should request to api gateway" do
        expect{ WebshotCreatorJob.new.perform(website.id) }.
          to raise_error(RestClient::NotFound)
      end
    end

    context "comment image doesn't exist" do
      it "should not request to api gateway" do
        expect(RestClient).to_not receive(:post)
        WebshotCreatorJob.new.perform(0)
      end
    end
  end

end
