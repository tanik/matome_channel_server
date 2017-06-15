require 'rails_helper'

RSpec.describe MyController, type: :controller do

  describe "#index" do
    context 'when user signed in' do
      let(:user){ FactoryGirl.create(:user) }
      let(:favorite_board){ FactoryGirl.create(:favorite_board, user: user) }
      let(:comments){ FactoryGirl.create_list(:comment, 10, board: favorite_board.board) }
      let(:histories){ FactoryGirl.create_list(:history, 5, user: user) }
      before do
        expect(Comment).to receive(:popular).
          with(anything, 3).and_return(populars)
        histories
        comments
        set_authentication_headers_for(user)
      end
      let(:populars){ FactoryGirl.create_list(:comment, 3) }
      it do
        get :index
        expect(response.body).to eq({
          comments: comments.reverse.map(&:to_user_params_with_board),
          populars: populars.map(&:to_user_params_with_board),
          recommends: [],
          histories: histories.reverse.map{|h| h.board.to_index_params }
        }.to_json)
      end
    end

    context 'when user not sign in' do
      it do
        get :index
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#comments" do
    context 'when user signed in' do
      let(:user){ FactoryGirl.create(:user) }
      let(:favorite_board){ FactoryGirl.create(:favorite_board, user: user) }
      let(:comments){ FactoryGirl.create_list(:comment, 10, board: favorite_board.board) }

      before{ set_authentication_headers_for(user) }

      it do
        comments
        get :comments
        expect(response.body).to eq(comments.reverse.map(&:to_user_params_with_board).to_json)
      end

      it do
        comments
        get :comments, params: {gt_id: comments[5]}
        expect(response.body).to eq(comments[6..-1].reverse.map(&:to_user_params_with_board).to_json)
      end
      it do
        comments
        get :comments, params: {lt_id: comments[5]}
        expect(response.body).to eq(comments[0..4].reverse.map(&:to_user_params_with_board).to_json)
      end
      it do
        comments
        get :comments, params: {gt_id: comments[2], lt_id: comments[6]}
        expect(response.body).to eq(comments[3..5].reverse.map(&:to_user_params_with_board).to_json)
      end
    end

    context 'when user not sign in' do
      it do
        get :comments
        expect(response.status).to eq(401)
      end
    end
  end
end
