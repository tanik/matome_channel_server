FactoryGirl.define do
  sequence :name do |n|
    "name #{n}"
  end

  factory :category do
    name { generate(:name) }

    trait :child do
      parent { FactoryGirl.create(:category, :root) }
    end

    trait :root do
      parent_id nil
    end

    trait :with_children do
      after(:create) do |board|
        board. << FactoryGirl.build(:comment)
      end
    end
  end
end
