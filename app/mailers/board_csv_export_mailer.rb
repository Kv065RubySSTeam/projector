# frozen_string_literal: true

class BoardCsvExportMailer < ApplicationMailer
  def send_csv(email, csv)
    attachments['data.csv'] = { mime_type: 'text/csv', content: csv }
    mail(to: email, subject: 'Data', body: 'Board CSV.')
  end
end
