class CommentParser < ApplicationJob
  queue_as :default

  def perform(comment_id)
    comment = Comment.find(comment_id) rescue nil
    return if comment.nil?
    URI.extract(comment.content).select{|url| url =~ /^(ttp:\/\/|ttps:\/\/|http:\/\/|https:\/\/)/}.each do |url|
      url = url.gsub(/^(ttp:\/\/|ttps:\/\/)/){|m|"h#{m}"}
    end
  end
end
