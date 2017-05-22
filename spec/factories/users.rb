FactoryGirl.define do
  sequence :user_email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    email { generate(:user_email) }
    password 'password'

    transient do
      confirmed true
    end

    before(:create) do |user, evaluator|
      if evaluator.try(:confirmed)
        user.skip_confirmation!
      end
    end
  end
end
