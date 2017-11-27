# frozen_string_literal: true

class GobiertoCalendarsEventRemoveAttachmentUrlColumn < ActiveRecord::Migration[5.1]
  def change
    remove_column :gobierto_calendars_events, :attachment_url
  end
end
