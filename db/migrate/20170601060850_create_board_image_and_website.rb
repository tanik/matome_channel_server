class CreateBoardImageAndWebsite < ActiveRecord::Migration[5.1]
  def up
    CommentImage.all.each do |ci|
      ci.comment.board.board_images.create(image: ci.image)
    end
    CommentWebsite.all.each do |cw|
      cw.comment.board.board_websites.create(website: cw.website)
    end
  end

  def down
    BoardImage.delete_all
    BoardWebsite.delete_all
  end
end
