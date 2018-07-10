# frozen_string_literal: true

class GobiertoCalendarsEventRemoveAttachmentUrlColumn < ActiveRecord::Migration[5.1]

  def change
    remove_column :gc_events, :attachment_url, :string
  end

end
