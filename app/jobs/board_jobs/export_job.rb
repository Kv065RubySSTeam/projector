# frozen_string_literal: true

module BoardJobs
  class ExportJob < ApplicationJob
    queue_as :default

    def perform(export_id, board)
      return if export_id.blank? && board.blank?

      csv_content = Boards::CsvExporter.new(board).call

      ActionCable.server.broadcast(
        "export_channel_#{export_id}",
        csv_file: {
          file_name: "board-#{board.id}-data.csv",
          content: csv_content
        }
      )
    end
  end
end
