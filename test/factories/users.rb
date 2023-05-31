FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.email }
  end
end
