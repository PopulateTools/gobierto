# frozen_string_literal: true

class AddGobiertoPeoplePoliticalGroupReferenceToPeople < ActiveRecord::Migration[5.0]
  def change
    add_reference :gp_people, :political_group
  end
end
