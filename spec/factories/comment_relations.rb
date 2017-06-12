FactoryGirl.define do
  factory :comment_relation do
    comment
    related_comment { FactoryGirl.create(:comment) }
  end
end
