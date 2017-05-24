FactoryGirl.define do
  factory :website do
    original_url "http://example.com"
    title "Example Site"
    thumbnail_url "http://s3.aws.com/websites/1_thumb.png"
    full_url "http://s3.aws.com/websites/1_full.png"
  end
end
