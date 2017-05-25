# frozen_string_literal: true

class AddGobiertoPeopleClassifyingFieldsIndexesToPeople < ActiveRecord::Migration[5.0]
  def change
    add_index :gp_people, :category
    add_index :gp_people, :party
    add_index :gp_people, %i[category party]
  end
end
