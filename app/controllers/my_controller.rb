class MyController < ApplicationController
  before_action :authenticate_user!

  def index
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

  def timeline_comments
    comments = Comment.where(board_id: current_user.favorite_boards.map(&:board_id)).
      includes(board: [:first_comment, :favorite_boards]).
      includes(:websites).includes(:images).includes(:favorite_comments).
      order(id: :desc).limit(20)
    comments = comments.gt(params[:gt_id]) if params[:gt_id].present?
    comments = comments.lt(params[:lt_id]) if params[:lt_id].present?
    render json: comments.map(&:to_user_params_with_board)
  end

  def boards
    boards = current_user.boards.order(id: :desc).includes(:first_comment).
      page(params[:page]).per(params[:per])
    render json: boards.map(&:to_index_params)
  end

  def favorite_boards
    boards = current_user.my_favorite_boards.order(id: :desc).includes(:first_comment).
      page(params[:page]).per(params[:per])
    render json: boards.map(&:to_index_params)
  end

  def comments
    comments = current_user.comments.order(id: :desc).
      includes(board: [:first_comment, :favorite_boards]).
      includes(:websites).includes(:images).includes(:favorite_comments).
      page(params[:page]).per(params[:per])
    render json: comments.map(&:to_user_params_with_board)
  end

  def favorite_comments
    comments = current_user.my_favorite_comments.order(id: :desc).
      includes(board: [:first_comment, :favorite_boards]).
      includes(:websites).includes(:images).includes(:favorite_comments).
      page(params[:page]).per(params[:per])
    render json: comments.map(&:to_user_params_with_board)
  end

  def histories
    render json: current_user.histories.order(id: :desc).map{|h| h.board.to_index_params }
  end
end
