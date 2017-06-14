class BoardsController < ApplicationController
  before_action :set_board, only: [:show, :favorite]
  before_action :authenticate_user!, only: [:favorite]

  # GET /boards
  def index
    if params[:q]
      @boards = Board.search(params[:q]).page(params[:page]).per(params[:per]).records
    else
      @boards = Board.order(score: :desc).page(params[:page]).per(params[:per])
    end
    if cid = params[:category_id]
      categories = Category.where(id: cid).or(Category.where(parent_id: cid))
      @boards = @boards.where(category_id: categories.map(&:id)) if categories.any?
    end
    render json: {
      boards: @boards.map(&:to_index_params),
      pagination: {
        per: @boards.limit_value,
        total: @boards.total_pages,
        current: @boards.current_page,
        next: @boards.next_page,
        prev: @boards.prev_page,
      }
    }
  end

  # GET /boards/1
  def show
    board = @board.to_show_params
    render json: board
  end

  # POST /boards
  def create
    @board = Board.new(board_params)
    @board.user = current_user
    @board.comments.last.remote_ip  = request.remote_ip
    @board.comments.last.user_agent = request.user_agent
    @board.comments.last.user = current_user
    if @board.save
      render json: @board, status: :created, location: @board
    else
      render json: @board.errors, status: :unprocessable_entity
    end
  end

  # PUT /board/:board_id/favorite
  def favorite
    favorite = current_user.favorite_boards.build(board: @board)
    if favorite.save
      render json: favorite
    else
      render json: favorite.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_board
      @board = Board.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def board_params
      params.require(:board).permit(:category_id, :title, comments_attributes: [:name, :content])
    end
end
