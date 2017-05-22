require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  describe "#index" do
    let(:categories){ FactoryGirl.create_list(:category, 10) }
    
    subject{ get :index  }
  end
end
