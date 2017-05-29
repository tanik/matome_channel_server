class CommentParser
  include Sidekiq::Worker

  sidekiq_options queue: 'default', retry: 10

  def perform(comment_id)
    comment = Comment.find(comment_id) rescue nil
    return if comment.nil?
    URI.extract(comment.content, ['http', 'https']) do |url|
      url = url.gsub(/^(ttp:\/\/|ttps:\/\/)/){|m|"h#{m}"}
      resp = RestClient.head(url)
      content_type = resp.headers[:content_type].to_s.downcase
      image = nil
      Image::PERMITTED_CONTENT_TYPES.each do |permitted_type|
        if content_type.include?(permitted_type)
          image = Image.find_or_create_by(original_url: url)
          comment.comment_images.create(image: image)
          break
        end
      end
      next if image
      # not image and movie
      website = Website.find_or_create_by(original_url: url)
      comment.comment_websites.create(website: website)
    end
  end
end
