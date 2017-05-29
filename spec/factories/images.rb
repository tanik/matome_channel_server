FactoryGirl.define do
  factory :image do
    original_url "http://example.com/example.png"
    thumbnail_url "/images/thumbnails/1.png"
    full_url "/images/images/1.png"
  end
end
