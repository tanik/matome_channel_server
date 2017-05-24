require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  describe "#index" do
    let(:categories){ FactoryGirl.create_list(:category, 10) }

    before{ categories }
    it do
      get :index
      expect(response.body).to eq(categories.to_json)
    end
  end
end
