FactoryBot.define do
  factory :membership do
    user
    board
    admin { true }
  end
end