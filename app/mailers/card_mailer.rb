class CardMailer < ApplicationMailer
  before_action { @card, @user = params[:card], params[:user] }
  
  def start_date_notify
    @board = @card.column.board
    @assignee = @card.assignee
    mail(to: @user.email, subject:"Card \"#{@card.title}\" planed for today.")
  end
end
