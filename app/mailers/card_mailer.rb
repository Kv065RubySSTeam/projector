class CardMailer < ApplicationMailer
  default from: "not-replay@projector.com"
  
  def new_assignee
    @card = params[:card]
    send_mail(@card, "User #{@card.assignee.first_name} were tagged as a assignee at the card \"#{@card.title}\"")
  end

  def added_comment
    @card = params[:card]
    send_mail(@card, "New comment added to the \"#{@card.title}\"")
  end

  def update_card_position
    @card = params[:card]
    send_mail(@card, "Card \"#{@card.title}\" was moved to another column")
  end

  private

  def send_mail(card, subject)
    if card.assignee.present?
      emails = [card.user.email, card.assignee.email]
      
      emails.each do |email|
        new_request(email, card, subject)
      end
    else
      new_request(card.user.email, card, subject)
    end
  end

   def new_request(email, card, subject)
      @board = card.column.board
      @column = card.column
      @assignee = card.assignee
      @user = User.find_by(email: email)
      mail(to: email, subject: subject) if @user.receive_emails
    end
end
