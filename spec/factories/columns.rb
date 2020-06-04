FactoryBot.define do
  factory :column do
    name { "name" }
    user { create(:user) }
    board { create(:board) }
    sequence(:position)
  end
end