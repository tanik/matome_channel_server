require "rails_helper"

RSpec.describe ContactsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(:post => "/contacts").to route_to("contacts#create")
    end
  end
end
