require 'faker'

FactoryBot.define do
  factory :board do
    title { Faker::Lorem.sentence(word_count: 3, supplemental: true) }
    description { Faker::Lorem.sentence(word_count: 3, supplemental: true) }
    user
    public { false }
    factory :public_board do
      public { true }
    end

    factory :board_with_columns do
      transient do
        columns_count { 10 }
      end
      after(:create) do |board, evaluator|
        create_list(:column, evaluator.columns_count, board: board)
      end
    end
    factory :board_with_cards do
      transient do
        columns_count { 3 }
      end
    end

    factory :board_with_columns_cards do
      transient do
        columns_count { 5 }
      end
      
      after(:create) do |board, evaluator|
        create_list(:column_with_cards, evaluator.columns_count, board: board)
      end
    end
  end
end
