# frozen_string_literal: true

class AddImageUrlToAnswerTemplates < ActiveRecord::Migration[5.1]
  def change
    add_column :gpart_poll_answer_templates, :image_url, :string
  end
end
