class MyController < ApplicationController
  before_action :authenticate_user!

  def index
    # TODO なんか遅いからちょっと考えねばならん・・たぶんto_user_params_with_boardが遅いN+1的なあれだとおもう。
    comments = Comment.where(board_id: current_user.favorite_boards.map(&:board_id)).
      order(id: :desc).limit(20)
    populars = Comment.popular(1.hour.ago, 3)
    histories = current_user.histories.order(id: :desc).limit(10)
    # TODO recommends and histories
    render json: {
      comments: comments.map(&:to_user_params_with_board),
      populars: populars.map(&:to_user_params_with_board),
      recommends: [],
      histories: histories.map{|h| h.board.to_index_params },
    }
  end

  def comments
    comments = Comment.where(board_id: current_user.favorite_boards.map(&:board_id)).
      order(id: :desc).limit(20)
    comments = comments.gt(params[:gt_id]) if params[:gt_id].present?
    comments = comments.lt(params[:lt_id]) if params[:lt_id].present?
    render json: comments.map(&:to_user_params_with_board)
  end
end
