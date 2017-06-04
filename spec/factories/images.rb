FactoryGirl.define do
  sequence :image_url do |n|
    "http://example.com/example-#{n}.png"
  end

  factory :image do
    original_url { generate(:image_url) }
    thumbnail_url "/images/thumbnails/1.png"
    full_url "/images/images/1.png"
    width 800
    height 600
  end
end
