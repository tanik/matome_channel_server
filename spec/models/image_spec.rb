require 'rails_helper'

RSpec.describe Image, type: :model do
  describe "validations" do
    describe "original_url" do

      subject{ FactoryGirl.build(:image, original_url: original_url) }

      context "is valid" do
        let(:original_url){ "http://example.com/example.png" }
        it{ is_expected.to be_valid }
      end
    end

    describe "content_type" do
      subject{ FactoryGirl.build(:image, content_type: content_type) }

      Image::PERMITTED_CONTENT_TYPES.each do |type|
        context "is #{type}" do
          let(:content_type){ type }
          it{ is_expected.to be_valid }
        end
      end
      context "is text/html" do
        let(:content_type){ "text/html" }
        it{ is_expected.to_not be_valid }
      end
    end
  end
end
