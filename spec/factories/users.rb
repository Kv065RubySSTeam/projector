require 'faker'

FactoryBot.define do
  factory :user do
    first_name { "Name" }
    last_name { "Last Name" }
    email { "#{Faker::Internet.email}" }
    password  { "password" }
    password_confirmation { "password" }
    confirmed_at {Time.now}
  end
end