# frozen_string_literal: true

class ExportChannel < ApplicationCable::Channel
  def subscribed
    stream_from "export_channel_#{params[:export_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
