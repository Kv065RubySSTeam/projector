# frozen_string_literal: true

class PasswordMailer < ApplicationMailer
  before_action { @user = params[:user] }

  def reset_password
    mail(to: @user.email, subject: 'Reset password instructions')
  end
end
