require 'rails_helper'

RSpec.describe ResourceCreatorJob, type: :job do

  describe "#perform_async" do
    it "matches with enqueued job" do
      expect{ ResourceCreatorJob.perform_async('Image', 1, 1) }.to change(ResourceCreatorJob.jobs, :size).by(1)
    end
  end

  describe "#perform" do
    context "when resource klass is Image" do
      let(:image){ FactoryGirl.create(:image, thumbnail_url: nil, full_url: nil, width: nil, height: nil) }
      let(:board_image){ FactoryGirl.create(:board_image, image: image) }
      let(:comment_image){ FactoryGirl.create(:comment_image, image: image) }
      let(:resp_hash){ {state: 'success', thumbnail: 'images/thumbnails/1.png', image: 'images/images/1.png', width: 200, height: 150} }
      let(:response){ resp_hash.to_json }
      let(:status){ 200 }
      before do
        stub_request(:post, "#{ENV['API_GATEWAY_ENDPOINT']}/images").with({
          body: {id: image.id, url: image.original_url, bucket: ENV['AWS_S3_BUCKET']}.to_json
        }).to_return({
          status: status,
          body: response
        })
      end

      context "comment image exists and api result is success" do
        it "should update thumbnail_url" do
          expect{ ResourceCreatorJob.new.perform("Image", image.id, board_image.id, comment_image.id) }.
            to change{ image.reload.thumbnail_url }.to(resp_hash[:thumbnail])
        end
        it "should update full_url" do
          expect{ ResourceCreatorJob.new.perform("Image", image.id, board_image.id, comment_image.id) }.
            to change{ image.reload.full_url }.to(resp_hash[:image])
        end
        it "should update width" do
          expect{ ResourceCreatorJob.new.perform("Image", image.id, board_image.id, comment_image.id) }.
            to change{ image.reload.width }.to(resp_hash[:width])
        end
        it "should update height" do
          expect{ ResourceCreatorJob.new.perform("Image", image.id, board_image.id, comment_image.id) }.
            to change{ image.reload.height }.to(resp_hash[:height])
        end
        it "should notify board_image_added and comment_image_added" do
          expect(BoardChannel).to receive(:broadcast_to).exactly(2)
          ResourceCreatorJob.new.perform("Image", image.id, board_image.id, comment_image.id)
        end
      end

      context "comment image exists and api result is failure" do
        let(:resp_hash){ {state: 'failure', message: "something wrong"} }
        it "should request to api gateway" do
          expect{ ResourceCreatorJob.new.perform("Image", image.id, board_image.id, comment_image.id) }.
            to raise_error("something wrong")
        end
      end

      context "comment image exists and http status is failed" do
        let(:status){ 404 }
        it "should request to api gateway" do
          expect{ ResourceCreatorJob.new.perform("Image", image.id, board_image.id, comment_image.id) }.
            to raise_error(RestClient::NotFound)
        end
      end

      context "comment image doesn't exist" do
        it "should not request to api gateway" do
          expect(RestClient).to_not receive(:post)
          ResourceCreatorJob.new.perform("Image", 0, board_image.id, comment_image.id)
        end
      end
    end

    context "when resource klass is Website" do
      let(:website){ FactoryGirl.create(:website, thumbnail_url: nil, full_url: nil, title: nil) }
      let(:board_website){ FactoryGirl.create(:board_website, website: website) }
      let(:comment_website){ FactoryGirl.create(:comment_website, website: website) }
      let(:resp_hash){ {state: 'success', thumbnail: 'websites/thumbnails/1.png', image: 'websites/images/1.png', title: "Example Site"} }
      let(:response){ resp_hash.to_json }
      let(:status){ 200 }
      before do
        stub_request(:post, "#{ENV['API_GATEWAY_ENDPOINT']}/webshots").with({
          body: {id: website.id, url: website.original_url, bucket: ENV['AWS_S3_BUCKET']}.to_json
        }).to_return({
          status: status,
          body: response
        })
      end

      context "comment website exists and api result is success" do
        it "should update thumbnail_url" do
          expect{ ResourceCreatorJob.new.perform("Website", website.id, board_website.id, comment_website.id) }.
            to change{ website.reload.thumbnail_url }.to(resp_hash[:thumbnail])
        end
        it "should update full_url" do
          expect{ ResourceCreatorJob.new.perform("Website", website.id, board_website.id, comment_website.id) }.
            to change{ website.reload.full_url }.to(resp_hash[:image])
        end
        it "should update title" do
          expect{ ResourceCreatorJob.new.perform("Website", website.id, board_website.id, comment_website.id) }.
            to change{ website.reload.title }.to(resp_hash[:title])
        end
        it "should notify board_website_added and comment_website_added" do
          expect(BoardChannel).to receive(:broadcast_to).exactly(2)
          ResourceCreatorJob.new.perform("Website", website.id, board_website.id, comment_website.id)
        end
      end

      context "comment website exists and api result is failure" do
        let(:resp_hash){ {state: 'failure', message: "something wrong"} }
        it "should request to api gateway" do
          expect{ ResourceCreatorJob.new.perform("Website", website.id, board_website.id, comment_website.id) }.
            to raise_error("something wrong")
        end
      end

      context "comment website exists and http status is failed" do
        let(:status){ 404 }
        it "should request to api gateway" do
          expect{ ResourceCreatorJob.new.perform("Website", website.id, board_website.id, comment_website.id) }.
            to raise_error(RestClient::NotFound)
        end
      end

      context "comment website doesn't exist" do
        it "should not request to api gateway" do
          expect(RestClient).to_not receive(:post)
          ResourceCreatorJob.new.perform("Website", 0, board_website.id, comment_website.id)
        end
      end
    end
  end

  describe "#get_endpoint" do
    subject{ ResourceCreatorJob.new.send(:get_endpoint, "UnknownClass") }
    it{ expect{ subject }.to raise_error(ArgumentError, "Unknown resource: UnknownClass") }
  end

  describe "#update_params" do
    subject{ ResourceCreatorJob.new.send(:update_params, "UnknownClass", {})  }
    it{ expect{ subject }.to raise_error(ArgumentError, "Unknown resource: UnknownClass") }
  end
end
