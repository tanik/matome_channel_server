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
  end
end
