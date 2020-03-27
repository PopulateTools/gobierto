# frozen_string_literal: true

class AddExternalIdToTerms < ActiveRecord::Migration[5.2]
  def change
    add_column :terms, :external_id, :string
  end
end
