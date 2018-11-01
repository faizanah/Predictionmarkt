FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "#{n}_#{Faker::Internet.email}" }
    password 'RohDo4veif6voh2r'
  end
end
