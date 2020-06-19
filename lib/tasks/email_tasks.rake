# frozen_string_literal: true

desc 'daily letters'
task send_daily_letters: :environment do
  @cards = Card.where(start_date: Date.today)
  @users = User.where(receive_emails: true)
  @users.each do |user|
    @cards_to_send = @cards.where('user_id=? OR assignee_id=?', user.id, user.id)
    TaskMailer.daily_letters(user, @cards_to_send).deliver! if @cards_to_send.any?
  end
end
