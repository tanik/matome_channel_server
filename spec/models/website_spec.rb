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

  describe "correct_title" do
    subject{ FactoryGirl.build(:website, title: title).save }

    context "when title length less than 255" do
      let(:title){ "あ" * 254 }
      it{ is_expected.to be_truthy }
      it{ subject; expect(Website.last.title).to eq(title)}
    end

    context "when title length less than 255" do
      let(:title){ "あ" * 255 }
      it{ is_expected.to be_truthy }
      it{ subject; expect(Website.last.title).to eq("あ"*254+"…")}
    end
  end
end
