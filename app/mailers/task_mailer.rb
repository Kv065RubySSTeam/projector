class TaskMailer < ApplicationMailer
  def daily_letters(user, cards)
    @user = user
    @cards = cards  
    mail(to: @user.email, subject: "Work plan for today.")
  end
end
