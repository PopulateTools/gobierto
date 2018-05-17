# frozen_string_literal: true

class AddDateToGobiertoPeopleGift < ActiveRecord::Migration[5.2]

  def change
    add_column :gp_gifts, :date, :date, null: false
  end

end
