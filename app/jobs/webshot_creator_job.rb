class WebshotCreatorJob
  include Sidekiq::Worker

  sidekiq_options queue: 'default', retry: 10

  def perform(website_id)
    website = Website.find(website_id) rescue nil
    return if website.nil?
    response = RestClient.post("#{ENV['API_GATEWAY_ENDPOINT']}/webshots",
      {id: website.id, url: website.original_url}.to_json,
      {content_type: :json, accept: :json, 'x-api-key' => ENV['API_GATEWAY_KEY']})
    if response.code == 200
      json = JSON.parse(response.body)
      if json['state'] == 'success'
        website.update(title: json['title'], thumbnail_url: json['thumbnail'], full_url: json['image'])
      else
        raise(json['message'])
      end
    end
  end
end
