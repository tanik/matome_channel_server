FactoryGirl.define do
  sequence :website_url do |n|
    "http://example.com/example-#{n}.png"
  end

  factory :website do
    original_url { generate(:website_url) }
    title "Example Site"
    thumbnail_url "http://s3.aws.com/websites/1_thumb.png"
    full_url "http://s3.aws.com/websites/1_full.png"
  end
end
