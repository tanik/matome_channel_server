require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  describe "#index" do
    let(:board){ FactoryGirl.create(:board) }
    let(:comments){ FactoryGirl.create_list(:comment, 10, board: board) }
    before{ comments }

    it do
      get :index, params: {board_id: board.id}
      expect(response.body).to eq(comments.reverse.map(&:to_user_params).to_json)
    end
  end

  describe "#popular" do
    context "when category_id exists" do
      let(:root_category){ FactoryGirl.create(:category, :root) }
      let(:child_category){ FactoryGirl.create(:category, parent: root_category) }
      let(:comments){ FactoryGirl.create_list(:comment, 5) }

      it do
        expect(Comment).to receive(:popular).
          with(anything, 10, [root_category.id, child_category.id]).and_return(comments)
        get :popular, params: {category_id: root_category}
        expect(response.body).to eq(comments.map(&:to_user_params_with_board).to_json)
      end
    end

    context "when category_id doesn't exist" do
      let(:comments){ FactoryGirl.create_list(:comment, 5) }
      it do
        expect(Comment).to receive(:popular).
          with(anything, 10, []).and_return(comments)
        get :popular
        expect(response.body).to eq(comments.map(&:to_user_params_with_board).to_json)
      end
    end
  end

  describe "#show_by_num" do
    let(:board){ FactoryGirl.create(:board) }
    let(:comment){ FactoryGirl.create(:comment, board: board) }
    let(:anchor_comment){ FactoryGirl.create(:comment_relation, comment: comment).related_comment }
    let(:anchored_comment){ FactoryGirl.create(:comment_relation, related_comment: comment).comment }

    before do
      comment
      anchor_comment
      anchored_comment
    end

    it do
      get :show_by_num, params: {board_id: board.id, num: comment.num}
      expect(response.body).to eq({
        comment: comment.to_user_params,
        related_comments: [
          anchored_comment.to_user_params,
          anchor_comment.to_user_params
        ]
      }.to_json)
    end
  end


  describe "#show" do
    let(:board){ FactoryGirl.create(:board) }
    let(:comment){ FactoryGirl.create(:comment, board: board) }
    let(:anchor_comment){ FactoryGirl.create(:comment_relation, comment: comment).related_comment }
    let(:anchored_comment){ FactoryGirl.create(:comment_relation, related_comment: comment).comment }

    before do
      comment
      anchor_comment
      anchored_comment
    end

    it do
      get :show, params: {board_id: board.id, id: comment.id}
      expect(response.body).to eq({
        comment: comment.to_user_params,
        related_comments: [
          anchored_comment.to_user_params,
          anchor_comment.to_user_params
        ]
      }.to_json)
    end
  end

  describe "#create" do
    let(:board){ FactoryGirl.create(:board) }
    let(:user){ FactoryGirl.create(:user) }
    let(:user_agent){ 'test-agent' }
    let(:remote_ip){ '192.168.0.1' }

    before do
      request.env['HTTP_USER_AGENT'] = user_agent
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(remote_ip)
    end

    context "when user signed in" do
      let(:user){ FactoryGirl.create(:user) }
      it do
        set_authentication_headers_for(user)
        expect{ post :create,
          params: {
            board_id: board.id,
            comment: {
              name: "test",
              content: "content test"
            }
          }
        }.to change(Comment, :count).by(1)
        expect(response.body).to eq(Comment.last.to_json)
        expect(Comment.last.user).to eq(user)
        expect(Comment.last.remote_ip).to eq(remote_ip)
        expect(Comment.last.user_agent).to eq(user_agent)
      end
    end

    context "when user didn't sign in" do
      it do
        expect{ post :create,
          params: {
            board_id: board.id,
            comment: {
              name: "test",
              content: "content test"
            }
          }
        }.to change(Comment, :count).by(1)
        expect(response.body).to eq(Comment.last.to_json)
        expect(Comment.last.user).to be_nil
      end
    end

    context "when posted data is invalid" do
      it do
        expect{ post :create,
          params: {
            board_id: board.id,
            comment: {
              name: "test",
              content: "" # empty content
            }
          }
        }.to_not change(Comment, :count)
        expect(response.status).to eq(422)
      end
    end
  end

  describe "#favorite" do
    let(:board){ FactoryGirl.create(:board) }
    let(:comment){ FactoryGirl.create(:comment, board: board) }

    context "when user signed in" do
      let(:user){ FactoryGirl.create(:user) }
      it do
        set_authentication_headers_for(user)
        expect{ put :favorite,
          params: {
            board_id: board.id,
            id: comment.id
          }
        }.to change(FavoriteComment, :count).by(1)
        expect(response.body).to eq(FavoriteComment.last.to_json)
        expect(FavoriteComment.last.user).to eq(user)
        expect(FavoriteComment.last.comment).to eq(comment)
      end
    end
    context "when the same favorite exists" do
      let(:user){ FactoryGirl.create(:user) }

      before{ FactoryGirl.create(:favorite_comment, user: user, comment: comment) }
      it do
        set_authentication_headers_for(user)
        expect{ put :favorite,
          params: {
            board_id: board.id,
            id: comment.id
          }
        }.to_not change(FavoriteComment, :count)
        expect(response.status).to eq(422)
      end
    end
    context "when user didn't sign in" do
      it do
        expect{ put :favorite,
          params: {
            board_id: board.id,
            id: comment.id
          }
        }.to_not change(FavoriteComment, :count)
        expect(response.status).to eq(401)
      end
    end
  end
end
