FactoryGirl.define do
  sequence :name do |n|
    "name #{n}"
  end

  factory :category do
    name { generate(:name) }
  end
end
