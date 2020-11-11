# frozen_string_literal: true

class AddPublishLastVersionAutomaticallyColumnToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :gplan_plans, :publish_last_version_automatically, :boolean, null: false, default: false
  end
end
