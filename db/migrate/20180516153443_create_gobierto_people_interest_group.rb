# frozen_string_literal: true

class CreateGobiertoPeopleInterestGroup < ActiveRecord::Migration[5.2]

  def change
    create_table :gp_interest_groups do |t|
      t.belongs_to :site, null: false
      t.string :name, null: false
      t.jsonb :meta
    end
  end

end
