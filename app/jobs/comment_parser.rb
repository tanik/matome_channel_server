class CommentParser
  include Sidekiq::Worker

  sidekiq_options queue: 'default', retry: 10

  def perform(comment_id)
    comment = Comment.find(comment_id) rescue nil
    return if comment.nil?
    parse_anchor(comment)
    parse_url(comment)
  end

  private
  def parse_anchor comment
    comment.content.scan(/>>(\d+)/).flatten.each do |num|
      related_comment = Comment.find_by(board_id: comment.board_id, num: num)
      comment.comment_relations.create(related_comment: related_comment) if related_comment
    end
  end

  def parse_url comment
    URI.extract(comment.content, ['http', 'https']) do |url|
      url = url.gsub(/^(ttp:\/\/|ttps:\/\/)/){|m|"h#{m}"}
      resp = RestClient.head(url)
      content_type = resp.headers[:content_type].to_s.downcase
      image = nil
      Image::PERMITTED_CONTENT_TYPES.each do |permitted_type|
        if content_type.include?(permitted_type)
          image = create_resource(Image, comment, url)
          break
        end
      end
      next if image
      # not image and movie
      create_resource(Website, comment, url)
    end
  end

  def create_resource klass, comment, url
    klass_name = klass.name.underscore
    klass_names = klass_name.pluralize
    resource = klass.find_by(original_url: url)
    created = false
    if resource.nil?
      resource = klass.create(original_url: url)
      created = true
    end
    board_resouce = comment.board.send("board_#{klass_names}").create(klass_name => resource)
    comment_resource = comment.send("comment_#{klass_names}").create(klass_name => resource)
    if created
      ResourceCreatorJob.perform_async(klass.name, resource.id, board_resouce.id, comment_resource.id)
    else
      BoardChannel.broadcast_to comment.board,
        action: "board_#{klass_name}_added",
        "board_#{klass_name}".to_sym =>  board_resouce.to_user_params if board_resouce.persisted?
      BoardChannel.broadcast_to comment.board,
        action: "comment_#{klass_name}_added",
        "comment_#{klass_name}".to_sym => comment_resource.to_user_params if comment_resource.persisted?
    end
  end
end
