# frozen_string_literal: true

class CreateGobiertoPeopleGift < ActiveRecord::Migration[5.2]

  def change
    create_table :gp_gifts do |t|
      t.belongs_to :person, null: false
      t.string :name, null: false
      t.string :reason
      t.jsonb :meta
    end
  end

end
