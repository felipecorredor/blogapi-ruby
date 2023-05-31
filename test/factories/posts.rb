FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    publised { [true, false].sample }
    association :user, factory: :user
  end

  factory :publised_post, class: 'Post' do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    publised { true }
    association :user, factory: :user
  end


end