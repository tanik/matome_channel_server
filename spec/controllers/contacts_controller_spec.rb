require 'rails_helper'

RSpec.describe ContactsController, type: :controller do

  let(:valid_attributes) {
    {
      email: "test@test.com",
      content: "test\ncontent",
    }
  }

  let(:invalid_attributes) {
    {
      email: "test", # not email
      content: "test\ncontent",
    }

  }

  let(:valid_session) { {} }

  before do
    stub_request(:post, ENV['SLACK_WEBHOOK_FOR_CONTACT_URL']).
      to_return(:status => 200, :body => "", :headers => {})
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Contact" do
        expect {
          post :create, params: {contact: valid_attributes}, session: valid_session
        }.to change(Contact, :count).by(1)
      end

      it "assigns a newly created contact as @contact" do
        post :create, params: {contact: valid_attributes}, session: valid_session
        expect(assigns(:contact)).to be_a(Contact)
        expect(assigns(:contact)).to be_persisted
      end

      it "redirects to the created contact" do
        post :create, params: {contact: valid_attributes}, session: valid_session
        expect(response.status).to eq(201)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved contact as @contact" do
        post :create, params: {contact: invalid_attributes}, session: valid_session
        expect(assigns(:contact)).to be_a_new(Contact)
      end

      it "re-renders the 'new' template" do
        post :create, params: {contact: invalid_attributes}, session: valid_session
        expect(response.status).to eq(422)
      end
    end
  end

end
