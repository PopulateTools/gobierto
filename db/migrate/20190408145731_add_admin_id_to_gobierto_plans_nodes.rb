# frozen_string_literal: true

class AddAdminIdToGobiertoPlansNodes < ActiveRecord::Migration[5.2]
  def change
    add_reference :gplan_nodes, :admin, index: true
  end
end
