require 'rails_helper'

RSpec.describe Board, type: :model do

  describe "#first_comment" do
    let(:board){ FactoryGirl.create :board, :with_comments }

    subject{ board.first_comment }

    it{ is_expected.to eq board.comments.first.content }
  end
end
