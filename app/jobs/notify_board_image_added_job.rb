class NotifyBoardImageAddedJob
  include Sidekiq::Worker

  sidekiq_options queue: 'default', retry: false

  def perform(id)
    board_image = BoardImage.find(id) rescue nil
    return if board_image.nil?
    image_created = false
    30.times do
      image = board_image.image.reload
      if image.thumbnail_url and image.full_url
        image_created = true
        break
      end
      sleep(1)
    end
    if image_created
      BoardChannel.broadcast_to board_image.board,
        action: :board_image_added,
        board_image: board_image.to_user_params
    else
      raise("board image isn't created yet.")
    end
  end
end
