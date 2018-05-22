# frozen_string_literal: true

class AddMetaToGobiertoCalendarsEvent < ActiveRecord::Migration[5.2]

  def change
    add_column :gc_events, :meta, :jsonb
  end

end
