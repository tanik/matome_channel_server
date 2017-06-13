class ContactsController < ApplicationController
  # POST /contacts
  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      render json: @contact, status: :created
    else
      render json: @contact.errors, status: :unprocessable_entity
    end
  end


  private
    # Only allow a trusted parameter "white list" through.
    def contact_params
      params.require(:contact).permit(:email, :content)
    end
end
