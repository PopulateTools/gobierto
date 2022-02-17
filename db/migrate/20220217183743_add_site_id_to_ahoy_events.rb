# frozen_string_literal: true

class AddSiteIdToAhoyEvents < ActiveRecord::Migration[6.0]
  def change
    add_reference :ahoy_visits, :site, index: true
  end
end
