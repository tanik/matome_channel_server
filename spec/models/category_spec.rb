require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "validations" do
    describe "name" do

      subject{ FactoryGirl.build(:category, name: name) }

      context "is valid" do
        let(:name){ "test name" }
        it{ is_expected.to be_valid }
      end

      context "is too long" do
        let(:name){ "a"*256 }
        it{ is_expected.to_not be_valid }
      end

      context "is too short" do
        let(:name){ "" }
        it{ is_expected.to_not be_valid }
      end
    end
  end

  describe "#root?" do
    subject{ category.root? }

    context "when category is root" do
      let(:category){ FactoryGirl.create(:category, :root) }
      it{ is_expected.to be_truthy }
    end

    context "when category is child" do
      let(:category){ FactoryGirl.create(:category, :child) }
      it{ is_expected.to be_falsey }
    end
  end

  describe "#children" do
    let(:root_category){ FactoryGirl.create(:category, :root) }
    let(:child_categories){ FactoryGirl.create_list(:category, 2, parent: root_category) }

    subject{ root_category.children }

    it{ is_expected.to eq child_categories }
  end

  describe "#nested_name" do
    let(:root_category){ FactoryGirl.create(:category, :root) }
    let(:child_category){ FactoryGirl.create(:category, parent: root_category) }

    subject{ child_category.nested_name }

    it{ is_expected.to eq "#{root_category.name} » #{child_category.name}"}
  end

  describe "#nested_names" do
    let(:root_category){ FactoryGirl.create(:category, :root) }
    let(:child_category){ FactoryGirl.create(:category, parent: root_category) }

    subject{ child_category.nested_names }

    it{ is_expected.to eq [root_category.name, child_category.name]}
  end
end
