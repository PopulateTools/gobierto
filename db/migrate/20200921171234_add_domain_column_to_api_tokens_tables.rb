# frozen_string_literal: true

class AddDomainColumnToApiTokensTables < ActiveRecord::Migration[6.0]
  def change
    add_column :user_api_tokens, :domain, :string
    add_column :admin_api_tokens, :domain, :string
  end
end
