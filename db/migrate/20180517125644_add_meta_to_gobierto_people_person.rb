# frozen_string_literal: true

class AddMetaToGobiertoPeoplePerson < ActiveRecord::Migration[5.2]

  def change
    add_column :gp_people, :meta, :jsonb
  end

end
