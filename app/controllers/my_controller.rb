class MyController < ApplicationController
  before_action :authenticate_user!

  def index
    # TODO なんか遅いからちょっと考えねばならん・・たぶんto_user_params_with_boardが遅いN+1的なあれだとおもう。
    comments = Comment.where(board_id: current_user.favorite_boards.map(&:board_id)).
      includes(board: [:first_comment, :favorite_boards]).
      includes(:websites).includes(:images).includes(:favorite_comments).
      order(id: :desc).limit(20)
    populars = Comment.popular(1.hour.ago, 3).
      includes(board: [:first_comment, :favorite_boards]).
      includes(:board).includes(:websites).includes(:images).includes(:favorite_comments)
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
      order(id: :desc).limit(20).
      includes(board: [:first_comment, :favorite_boards]).
      includes(:board).includes(:websites).includes(:images).includes(:favorite_comments)
    comments = comments.gt(params[:gt_id]) if params[:gt_id].present?
    comments = comments.lt(params[:lt_id]) if params[:lt_id].present?
    render json: comments.map(&:to_user_params_with_board)
  end
end
