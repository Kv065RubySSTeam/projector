# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'kv.065.ruby@gmail.com'
  layout 'mailer'
end
