class ResourceCreatorJob
  include Sidekiq::Worker

  sidekiq_options queue: 'default', retry: 10

  def perform(klass_name, resouce_id, board_resource_id, comment_resource_id)
    resource_name = klass_name.underscore
    resource_klass = klass_name.constantize
    board_resource_klass = "Board#{klass_name}".constantize
    comment_resource_klass = "Comment#{klass_name}".constantize
    resource = resource_klass.find(resouce_id) rescue nil
    board_resource = board_resource_klass.find(board_resource_id) rescue nil
    comment_resource = comment_resource_klass.find(comment_resource_id) rescue nil
    return if resource.nil?
    endpoint = get_endpoint(klass_name)
    response = RestClient.post(endpoint,
      {id: resource.id, url: resource.original_url, bucket: ENV['AWS_S3_BUCKET']}.to_json,
      {content_type: :json, accept: :json, 'x-api-key' => ENV['API_GATEWAY_KEY']})
    if response.code == 200
      json = JSON.parse(response.body)
      if json['state'] == 'success'
        resource.update(update_params(klass_name, json))
        board_resource.board.update(thumbnail_url: resource.thumbnail)
        BoardChannel.broadcast_to board_resource.board,
          action: "board_#{resource_name}_added",
          "board_#{resource_name}".to_sym => board_resource.to_user_params if board_resource
        BoardChannel.broadcast_to comment_resource.comment.board,
          action: "comment_#{resource_name}_added",
          "comment_#{resource_name}".to_sym => comment_resource.to_user_params if comment_resource
      else
        raise(json['message'])
      end
    end
  end

  def get_endpoint klass_name
    case klass_name
    when "Image"
      return("#{ENV['API_GATEWAY_ENDPOINT']}/images")
    when "Website"
      return("#{ENV['API_GATEWAY_ENDPOINT']}/webshots")
    else
      raise ArgumentError.new("Unknown resource: #{klass_name}")
    end
  end

  def update_params klass_name, json
    case klass_name
    when "Image"
      return({
        thumbnail_url: json['thumbnail'],
        full_url: json['image'],
        width: json['width'],
        height: json['height'],
      })
    when "Website"
      return({
        title: json['title'],
        thumbnail_url: json['thumbnail'],
        full_url: json['image'],
      })
    else
      raise ArgumentError.new("Unknown resource: #{klass_name}")
    end
  end
end
