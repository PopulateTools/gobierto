# frozen_string_literal: true

class AddCommentsCountToComment < ActiveRecord::Migration[5.1]
  def change
    add_column :gpart_comments, :comments_count, :integer, default: 0
  end
end
