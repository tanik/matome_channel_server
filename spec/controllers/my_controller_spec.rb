require 'rails_helper'

RSpec.describe MyController, type: :controller do

  describe "#index" do
    context 'when user signed in' do
      let(:user){ FactoryGirl.create(:user) }
      let(:favorite_board){ FactoryGirl.create(:favorite_board, user: user) }
      let(:comments){ FactoryGirl.create_list(:comment, 10, board: favorite_board.board) }
      let(:histories){ FactoryGirl.create_list(:history, 5, user: user) }
      before do
        expect(Comment).to receive_message_chain(:popular, :includes, :includes, :includes, :includes, :includes)
          .and_return(populars)
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

  describe "#timeline_comments" do
    context 'when user signed in' do
      let(:user){ FactoryGirl.create(:user) }
      let(:favorite_board){ FactoryGirl.create(:favorite_board, user: user) }
      let(:comments){ FactoryGirl.create_list(:comment, 10, board: favorite_board.board) }

      before{ set_authentication_headers_for(user) }

      it do
        comments
        get :timeline_comments
        expect(response.body).to eq(comments.reverse.map(&:to_user_params_with_board).to_json)
      end

      it do
        comments
        get :timeline_comments, params: {gt_id: comments[5]}
        expect(response.body).to eq(comments[6..-1].reverse.map(&:to_user_params_with_board).to_json)
      end
      it do
        comments
        get :timeline_comments, params: {lt_id: comments[5]}
        expect(response.body).to eq(comments[0..4].reverse.map(&:to_user_params_with_board).to_json)
      end
      it do
        comments
        get :timeline_comments, params: {gt_id: comments[2], lt_id: comments[6]}
        expect(response.body).to eq(comments[3..5].reverse.map(&:to_user_params_with_board).to_json)
      end
    end

    context 'when user not sign in' do
      it do
        get :timeline_comments
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#boards" do
    context 'when user signed in' do
      let(:user){ FactoryGirl.create(:user) }
      let(:my_boards){ FactoryGirl.create_list(:board, 5, user: user)}
      let(:other_boards){ FactoryGirl.create_list(:board, 5) }

      before do
        my_boards
        other_boards
        set_authentication_headers_for(user)
      end

      it do
        get :boards
        expect(response.body).to eq(my_boards.reverse.map(&:to_index_params).to_json)
      end
    end

    context 'when user not sign in' do
      it do
        get :boards
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#favorite_boards" do
    context 'when user signed in' do
      let(:user){ FactoryGirl.create(:user) }
      let(:my_favorite_boards){ FactoryGirl.create_list(:favorite_board, 5, user: user)}
      let(:other_favorite_boards){ FactoryGirl.create_list(:favorite_board, 5) }

      before do
        my_favorite_boards
        other_favorite_boards
        set_authentication_headers_for(user)
      end

      it do
        get :favorite_boards
        expect(response.body).to eq(my_favorite_boards.map(&:board).reverse.map(&:to_index_params).to_json)
      end
    end

    context 'when user not sign in' do
      it do
        get :favorite_boards
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#comments" do
    context 'when user signed in' do
      let(:user){ FactoryGirl.create(:user) }
      let(:my_comments){ FactoryGirl.create_list(:comment, 5, user: user)}
      let(:other_comments){ FactoryGirl.create_list(:comment, 5) }

      before do
        my_comments
        other_comments
        set_authentication_headers_for(user)
      end

      it do
        get :comments
        expect(response.body).to eq(my_comments.reverse.map(&:to_user_params_with_board).to_json)
      end
    end

    context 'when user not sign in' do
      it do
        get :comments
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#favorite_comments" do
    context 'when user signed in' do
      let(:user){ FactoryGirl.create(:user) }
      let(:my_favorite_comments){ FactoryGirl.create_list(:favorite_comment, 5, user: user)}
      let(:other_favorite_comments){ FactoryGirl.create_list(:favorite_comment, 5) }

      before do
        my_favorite_comments
        other_favorite_comments
        set_authentication_headers_for(user)
      end

      it do
        get :favorite_comments
        expect(response.body).to eq(my_favorite_comments.map(&:comment).reverse.map(&:to_user_params_with_board).to_json)
      end
    end

    context 'when user not sign in' do
      it do
        get :favorite_comments
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#histories" do
    context 'when user signed in' do
      let(:user){ FactoryGirl.create(:user) }
      let(:my_histories){ FactoryGirl.create_list(:history, 5, user: user)}
      let(:other_histories){ FactoryGirl.create_list(:history, 5) }

      before do
        my_histories
        other_histories
        set_authentication_headers_for(user)
      end

      it do
        get :histories
        expect(response.body).to eq(my_histories.reverse.map{|h| h.board.to_index_params }.to_json)
      end
    end

    context 'when user not sign in' do
      it do
        get :histories
        expect(response.status).to eq(401)
      end
    end
  end
end
