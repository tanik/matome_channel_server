require 'rails_helper'

RSpec.describe ImageGetterJob, type: :job do
  let(:image){ FactoryGirl.create(:image, thumbnail_url: nil, full_url: nil) }
  let(:resp_hash){ {state: 'success', thumbnail: 'images/thumbnails/1.png', image: 'images/images/1.png'} }
  let(:response){ resp_hash.to_json }
  let(:status){ 200 }
  before do
    stub_request(:post, "#{ENV['API_GATEWAY_ENDPOINT']}/images").with({
      body: {id: image.id, url: image.original_url}.to_json
    }).to_return({
      status: status,
      body: response
    })
  end


  describe "#perform_async" do
    it "matches with enqueued job" do
      expect{ image.send(:get_image) }.to change(ImageGetterJob.jobs, :size).by(1)
    end
  end

  describe "#perform" do
    context "comment image exists and api result is success" do
      it "should request to api gateway" do
        expect{ ImageGetterJob.new.perform(image.id) }.
          to change{ image.reload.thumbnail_url }.to(resp_hash[:thumbnail])
      end
      it "should request to api gateway" do
        expect{ ImageGetterJob.new.perform(image.id) }.
          to change{ image.reload.full_url }.to(resp_hash[:image])
      end
    end

    context "comment image exists and api result is failure" do
      let(:resp_hash){ {state: 'failure', message: "something wrong"} }
      it "should request to api gateway" do
        expect{ ImageGetterJob.new.perform(image.id) }.
          to raise_error("something wrong")
      end
    end

    context "comment image exists and http status is failed" do
      let(:status){ 404 }
      it "should request to api gateway" do
        expect{ ImageGetterJob.new.perform(image.id) }.
          to raise_error(RestClient::NotFound)
      end
    end

    context "comment image doesn't exist" do
      it "should not request to api gateway" do
        expect(RestClient).to_not receive(:post)
        ImageGetterJob.new.perform(0)
      end
    end
  end

end
