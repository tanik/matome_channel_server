FactoryGirl.define do
  factory :image do
    original_url "http://example.com/example.png"
    content_type "image/png"
    thumbnail_url "http://s3.aws.com/images/1_thumb.png"
    full_url "http://s3.aws.com/images/1_full.png"
  end
end
