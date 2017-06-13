require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe "#validations" do
    describe "#email" do
      let(:contact){ FactoryGirl.build(:contact, email: email) }

      subject{ contact }

      context "when email is correct data" do
        let(:email){ "test@example.com" }
        it{ is_expected.to be_valid }
      end
      context "when email is blank" do
        let(:email){ "" }
        it{ is_expected.to_not be_valid }
      end
      context "when email is not email format" do
        let(:email){ "aaa" }
        it{ is_expected.to_not be_valid }
      end
    end

    describe "#content" do
      let(:contact){ FactoryGirl.build(:contact, content: content) }

      subject{ contact }

      context "when content is correct data" do
        let(:content){ "correct content" }
        it{ is_expected.to be_valid }
      end
      context "when content is too short" do
        let(:content){ "" }
        it{ is_expected.to_not be_valid }
      end
      context "when content is too short" do
        let(:content){ "a" * 65536 }
        it{ is_expected.to_not be_valid }
      end
    end
  end

  describe "#notify_by_slack" do
    before do
      stub_request(:post, ENV['SLACK_WEBHOOK_FOR_CONTACT_URL']).
        to_return(:status => 200, :body => "", :headers => {})
    end

    let(:email){ "test@example.com" }
    let(:content){ "contact\ncontent" }
    let(:message) do
      <<~EOS
        メールアドレス:
        #{email}

        問い合わせ内容:
        #{content}
      EOS
    end
    let(:contact){ FactoryGirl.create(:contact, email: email, content: content) }

    subject{ contact }

    it "should call slack api correctly" do
      expect_any_instance_of(Slack::Notifier).to receive(:ping).
        with(text: message).and_call_original
      subject
    end
  end
end
