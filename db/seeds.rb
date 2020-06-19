# For create user after running migration, type $ rake db:seed
FactoryBot.create(:user, email: 'admin@gmail.com', password: 'admins', password_confirmation: 'admins', receive_emails: true )
user = User.find_by_email('admin@gmail.com');

10.times do
  FactoryBot.create :user

FactoryBot.create_list(:board_with_columns_cards, 5, user: user )

boards = Board.all

boards.each do |board| 
  FactoryBot.create(:membership, user: user, board: board, admin: true)
end
