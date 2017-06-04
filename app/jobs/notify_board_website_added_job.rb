class NotifyBoardWebsiteAddedJob
  include Sidekiq::Worker

  sidekiq_options queue: 'default', retry: false

  def perform(id)
    board_website = BoardWebsite.find(id) rescue nil
    return if board_website.nil?
    website_created = false
    30.times do
      website = board_website.website.reload
      if website.thumbnail_url and website.full_url
        website_created = true
        break
      end
      sleep(1)
    end
    if website_created
      BoardChannel.broadcast_to board_website.board,
        action: :board_website_added,
        board_website: board_website.to_user_params
    else
      raise("board website isn't created yet.")
    end
  end
end
