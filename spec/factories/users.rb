require 'faker'
require 'securerandom'

FactoryBot.define do
  secure_password = SecureRandom.hex(16)

  factory :user do
    email { Faker::Internet.unique.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    password { secure_password }
    password_confirmation { secure_password }

    confirmed_at { Time.now } 
  end
end
