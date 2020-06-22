class CardMailer < ApplicationMailer
  before_action { @card, @user = params[:card], params[:user] }
  default from: 'kv.065.ruby@gmail.com'

  def new_assignee
    send_mail("User #{@card.assignee.first_name} were tagged as a assignee at the card \"#{@card.title}\"")
  end

  def added_comment
    send_mail("New comment added to the \"#{@card.title}\"")
  end

  def update_card_position
    send_mail("Card \"#{@card.title}\" was moved to another column")
  end

  private
  def send_mail(subject)
    @board = @card.column.board
    @column = @card.column
    @assignee = @card.assignee
    mail(to: @user.email, subject: subject)
  end
end
