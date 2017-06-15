FactoryGirl.define do
  sequence :title do |n|
    "title #{n}"
  end
  sequence :board_score do |n|
    n
  end

  factory :board do
    category
    user
    title { generate(:title) }
    score { generate(:board_score) }

    trait :with_comments do
      after(:create) do |board|
        board.comments << FactoryGirl.build(:comment)
      end
    end
  end
end
