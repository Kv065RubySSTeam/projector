require 'faker'

FactoryBot.define do
  factory :board do
    title { Faker::Name.name }
    description { Faker::Name.name }
    user
  end
end
