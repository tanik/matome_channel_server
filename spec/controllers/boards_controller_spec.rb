require 'rails_helper'

RSpec.describe BoardsController, type: :controller do
  describe "#index" do

    context "when category isn't selected" do
      let(:boards){ FactoryGirl.create_list(:board, 10) }

      before{ boards }

      it do
        get :index
        expect(response.body).to eq({
          boards: boards.sort{|a,b| b.score <=> a.score }.map(&:to_index_params),
          pagination: {
            per: 25,
            total: 1,
            current: 1,
            next: nil,
            prev: nil,
          }
        }.to_json)
      end
    end

    context "when category is selected" do
      let(:matched_boards){ FactoryGirl.create_list(:board, 10, category: matched_category) }
      let(:unmatched_boards){ FactoryGirl.create_list(:board, 10, category: unmatched_category) }
      let(:matched_category){ FactoryGirl.create(:category) }
      let(:unmatched_category){ FactoryGirl.create(:category) }

      before do
        matched_boards
        unmatched_boards
      end

      it do
        get :index, params: {category_id: matched_category.id}
        expect(response.body).to eq({
          boards: matched_boards.sort{|a,b| b.score <=> a.score }.map(&:to_index_params),
          pagination: {
            per: 25,
            total: 1,
            current: 1,
            next: nil,
            prev: nil,
          }
        }.to_json)
      end
    end
  end

  describe "#images" do
    let(:board){ FactoryGirl.create(:board) }
    let(:board_images){ FactoryGirl.create_list(:board_image, 10, board: board) }

    it do
      board_images
      get :images, params: {id: board.id}
      expect(response.body).to eq(board_images.reverse.map(&:to_user_params).to_json)
    end

    it do
      board_images
      get :images, params: {id: board.id, gt_id: board_images[5]}
      expect(response.body).to eq(board_images[6..-1].reverse.map(&:to_user_params).to_json)
    end
    it do
      board_images
      get :images, params: {id: board.id, lt_id: board_images[5]}
      expect(response.body).to eq(board_images[0..4].reverse.map(&:to_user_params).to_json)
    end
    it do
      board_images
      get :images, params: {id: board.id, gt_id: board_images[2], lt_id: board_images[6]}
      expect(response.body).to eq(board_images[3..5].reverse.map(&:to_user_params).to_json)
    end
  end

  describe "#websites" do
    let(:board){ FactoryGirl.create(:board) }
    let(:board_websites){ FactoryGirl.create_list(:board_website, 10, board: board) }

    it do
      board_websites
      get :websites, params: {id: board.id}
      expect(response.body).to eq(board_websites.reverse.map(&:to_user_params).to_json)
    end

    it do
      board_websites
      get :websites, params: {id: board.id, gt_id: board_websites[5]}
      expect(response.body).to eq(board_websites[6..-1].reverse.map(&:to_user_params).to_json)
    end
    it do
      board_websites
      get :websites, params: {id: board.id, lt_id: board_websites[5]}
      expect(response.body).to eq(board_websites[0..4].reverse.map(&:to_user_params).to_json)
    end
    it do
      board_websites
      get :websites, params: {id: board.id, gt_id: board_websites[2], lt_id: board_websites[6]}
      expect(response.body).to eq(board_websites[3..5].reverse.map(&:to_user_params).to_json)
    end
  end

  describe "#show" do
    let(:board){ FactoryGirl.create(:board) }

    before{ board }

    context "when user signed in" do
      let(:user){ FactoryGirl.create(:user) }
      it do
        set_authentication_headers_for(user)
        expected = board.to_show_params
        get :show, params: { id: board.id }
        expect(response.body).to eq(expected.to_json)
      end
    end

    context "when user didn't sign in" do
      it do
        expected = board.to_show_params
        get :show, params: { id: board.id }
        expect(response.body).to eq(expected.to_json)
      end
    end
  end

  describe "#create" do
    let(:title){ "Test Title" }
    let(:name){ "Test Name" }
    let(:content){ "Test Content" }
    let(:user_agent){ 'test-agent' }
    let(:remote_ip){ '192.168.0.1' }
    let(:category){ FactoryGirl.create(:category) }
    let(:user){ FactoryGirl.create(:user) }

    before do
      request.env['HTTP_USER_AGENT'] = user_agent
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(remote_ip)
    end

    context "when user signed in" do
      it do
        set_authentication_headers_for(user)
        expect{ post :create,
          params: {
            board: {
              category_id: category.id,
              title: title,
              comments_attributes: [{
                name: name,
                content: content,
              }]
            }
          }
        }.to change(Board, :count).by(1).and change(Comment, :count).by(1)
        expect(response.body).to eq(Board.last.to_json)
        expect(Board.last.user).to eq(user)
        expect(Board.last.category).to eq(category)
        expect(Comment.last.user).to eq(user)
        expect(Comment.last.name).to eq(name)
        expect(Comment.last.content).to eq(content)
        expect(Comment.last.user_agent).to eq(user_agent)
        expect(Comment.last.remote_ip).to eq(remote_ip)
      end
    end

    context "when user didn't sign in" do
      it do
        expect{ post :create,
          params: {
            board: {
              category_id: category.id,
              title: title,
              comments_attributes: [{
                name: name,
                content: content,
              }]
            }
          }
        }.to change(Board, :count).by(1).and change(Comment, :count).by(1)
        expect(response.body).to eq(Board.last.to_json)
        expect(Board.last.user).to be_nil
        expect(Board.last.category).to eq(category)
        expect(Comment.last.user).to be_nil
        expect(Comment.last.name).to eq(name)
        expect(Comment.last.content).to eq(content)
        expect(Comment.last.user_agent).to eq(user_agent)
        expect(Comment.last.remote_ip).to eq(remote_ip)
      end
    end

    context "when board title is empty" do
      let(:title){ "" }
      it do
        expect{ post :create,
          params: {
            board: {
              category_id: category.id,
              title: title,
              comments_attributes: [{
                name: name,
                content: content,
              }]
            }
          }
        }.to_not change(Board, :count)
        expect(response.status).to eq(422)
      end
    end
    context "when comment content is empty" do
      let(:content){ "" }
      it do
        expect{ post :create,
          params: {
            board: {
              category_id: category.id,
              title: title,
              comments_attributes: [{
                name: name,
                content: content,
              }]
            }
          }
        }.to_not change(Board, :count)
        expect(response.status).to eq(422)
      end
    end
  end

  describe "#favorite" do
    let(:board){ FactoryGirl.create(:board) }

    context "when user signed in" do
      let(:user){ FactoryGirl.create(:user) }
      it do
        set_authentication_headers_for(user)
        expect{ put :favorite,
          params: {
            id: board.id,
          }
        }.to change(FavoriteBoard, :count).by(1)
        expect(response.body).to eq(FavoriteBoard.last.to_json)
        expect(FavoriteBoard.last.user).to eq(user)
        expect(FavoriteBoard.last.board).to eq(board)
      end
    end
    context "when the same favorite exists" do
      let(:user){ FactoryGirl.create(:user) }

      before{ FactoryGirl.create(:favorite_board, user: user, board: board) }
      it do
        set_authentication_headers_for(user)
        expect{ put :favorite,
          params: {
            id: board.id,
          }
        }.to_not change(FavoriteBoard, :count)
        expect(response.status).to eq(422)
      end
    end
    context "when user didn't sign in" do
      it do
        expect{ put :favorite,
          params: {
            id: board.id,
          }
        }.to_not change(FavoriteBoard, :count)
        expect(response.status).to eq(401)
      end
    end
  end
end
