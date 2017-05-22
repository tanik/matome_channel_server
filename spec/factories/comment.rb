FactoryGirl.define do
  sequence :content do |n|
    "content #{n}"
  end

  factory :comment do
    name "名無しさん"
    content { generate(:content) }
    remote_ip "1.2.3.4"
    user_agent "sample-agent"
  end
end
