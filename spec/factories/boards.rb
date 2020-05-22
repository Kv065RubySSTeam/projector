require 'faker'

FactoryBot.define do
  factory :board do
    title { Faker::Name.name }
    description { Faker::Name.name }
    user
    
    factory :board_with_columns do
      transient do
        columns_count { 10 }
      end
      after(:create) do |board, evaluator|
        create_list(:column, evaluator.columns_count, board: board)
      end
    end

  end
end
