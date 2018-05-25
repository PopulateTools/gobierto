# frozen_string_literal: true

class RemoveMetaFromGobiertoPeoplePerson < ActiveRecord::Migration[5.2]

  def change
    remove_column :gp_people, :meta
  end

end
