class CommentsController < ApplicationController
  before_action :set_board
  before_action :authenticate_user!, only: [:favorite]
  before_action :set_comment, only: [:show, :favorite]

  # GET /board/:board_id/comments
  def index
    @comments = @board.comments.page(params[:page]).per(params[:per])
    render json: @comments
  end

  # GET  /board/:board_id/comments/1
  def show
    render json: @comment
  end

  # POST  /board/:board_id/comments
  def create
    @comment = @board.comments.build(comment_params)
    @comment.remote_ip  = request.remote_ip
    @comment.user_agent = request.user_agent
    @comment.user = current_user
    if @comment.save
      render json: @comment, status: :created, location: [@board, @comment]
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PUT /board/:board_id/comments/1/favorite
  def favorite
    favorite = current_user.favorite_comments.build(comment: @comment)
    if favorite.save
      render json: favorite
    else
      render json: favorite.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_board
      @board = Board.find(params[:board_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def comment_params
      params.require(:comment).permit(:name, :content)
    end
end
