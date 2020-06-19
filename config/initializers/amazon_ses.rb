# frozen_string_literal: true

ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
                                       :server => 'email.us-west-2.amazonaws.com',
                                       :access_key_id => Rails.application.credentials.aws[:access_key_id],
                                       :secret_access_key => Rails.application.credentials.aws[:secret_access_key]
