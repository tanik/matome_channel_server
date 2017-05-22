FactoryGirl.define do
  sequence :title do |n|
    "title #{n}"
  end

  factory :board do
    category
    user
    title { generate(:title) }

    trait :with_comments do
      after(:create) do |board|
        board.comments << FactoryGirl.build(:comment)
      end
    end
  end
end
