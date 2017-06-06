class ImageGetterJob
  include Sidekiq::Worker

  sidekiq_options queue: 'default', retry: 10

  def perform(id)
    image = Image.find(id) rescue nil
    return if image.nil?
    response = RestClient.post("#{ENV['API_GATEWAY_ENDPOINT']}/images",
      {id: image.id, url: image.original_url, bucket: ENV['AWS_S3_BUCKET']}.to_json,
      {content_type: :json, accept: :json, 'x-api-key' => ENV['API_GATEWAY_KEY']})
    if response.code == 200
      json = JSON.parse(response.body)
      if json['state'] == 'success'
        image.update(thumbnail_url: json['thumbnail'],
                     full_url: json['image'],
                     width: json['width'],
                     height: json['height'])
      else
        raise(json['message'])
      end
    end
  end
end
