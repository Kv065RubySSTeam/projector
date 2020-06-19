FactoryBot.define do
  factory :membership do
    board
    user
    admin { false }

    factory :admin_membership do
      admin { true }
    end

    factory :administrated_board do
      transient do
        board_count { 1 }
      end

      after(:create) do |board, evaluator|
        create_list(:board, evaluator.boards_count, board: board)
      end
    end
    
  end
end
