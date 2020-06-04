FactoryBot.define do
  factory :membership do
    user 
    board 
    admin { false }

    factory :admin_membership do
      admin { true }
    end
    
  end
end
