require 'rails_helper'

RSpec.describe User, type: :model do

  describe "#add_history" do
    let(:user){ FactoryGirl.create(:user) }
    let(:board){ FactoryGirl.create(:board) }
    subject{ user.add_history board }

    context "when the same board has already exist" do
      let(:old_hisotory){ FactoryGirl.create(:history, user: user, board: board) }
      before{ old_hisotory }
      it{ expect{ subject }.to_not change(History, :count) }
      it{ subject; expect( user.histories.last.board ).to eq(board) }
      it{ subject; expect( user.histories.last.id ).to_not eq(old_hisotory.id) }
    end
    context "when the same board doesn't exist" do
      it{ expect{ subject }.to change(History, :count).by(1) }
    end
    context "when the 30 history exist" do
      before{ FactoryGirl.create_list(:history, 30, user: user) }
      it{ expect{ subject }.to_not change(History, :count) }
      it{ subject; expect( user.reload.histories.last.board ).to eq(board) }
    end
  end

end
