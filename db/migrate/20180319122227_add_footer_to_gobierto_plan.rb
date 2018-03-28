# frozen_string_literal: true

class AddFooterToGobiertoPlan < ActiveRecord::Migration[5.1]
  def change
    add_column :gplan_plans, :footer_translations, :jsonb
  end
end
