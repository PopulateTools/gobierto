# frozen_string_literal: true

class AddDepartmentToGobiertoCalendarsEvent < ActiveRecord::Migration[5.2]

  def change
    add_column :gc_events, :department_id, :bigint
    add_index :gc_events, :department_id
  end

end
