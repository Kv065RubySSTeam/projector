# frozen_string_literal: true

module BoardJobs
  class ExportMailJob < ApplicationJob
    queue_as :mailers

    def perform(email, board)
      csv_content = Boards::CsvExporter.new(board).call
      BoardCsvExportMailer.send_csv(email, csv_content).deliver_now
    end
  end
end
