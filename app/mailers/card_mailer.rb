class CardMailer < ApplicationMailer
  before_action do
    @card, @user, @board = params[:card], params[:user], params[:board]
  end 
  # TODO: default в config
  default from: "not-replay@projector.com"
  
  def add_assignee_notification
    send_mail("User #{@card.assignee.first_name} were tagged as a assignee at the card \"#{@card.title}\"")
  end

  def add_comment_notification
    send_mail("New comment added to the \"#{@card.title}\"")
  end

  def move_card_notification
    send_mail("Card \"#{@card.title}\" was moved to another column")
  end

  def destroy_card_notification
    send_mail("Card \"#{@card.title}\" has been deleted from \"#{@board}\"")
  end

  private
  def send_mail(subject)
    @board = @card.column.board
    @column = @card.column
    @assignee = @card.assignee
    mail(to: @user.email, subject: subject)
  end
end
