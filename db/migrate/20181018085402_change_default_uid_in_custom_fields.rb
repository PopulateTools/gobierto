# frozen_string_literal: true

class ChangeDefaultUidInCustomFields < ActiveRecord::Migration[5.2]
  def change
    change_column_default :custom_fields, :uid, from: "", to: nil
  end
end
