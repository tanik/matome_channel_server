require 'rails_helper'

RSpec.describe Website, type: :model do
  describe "validations" do
    describe "original_url" do

      subject{ FactoryGirl.build(:website, original_url: original_url) }

      context "is valid" do
        let(:original_url){ "http://example.com/example.png" }
        it{ is_expected.to be_valid }
      end
    end

    describe "title" do
      subject{ FactoryGirl.build(:website, title: title) }

      context "is valid" do
        let(:title){ "Example Page" }
        it{ is_expected.to be_valid }
      end
    end
  end
end
