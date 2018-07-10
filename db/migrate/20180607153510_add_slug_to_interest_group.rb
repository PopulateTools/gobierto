# frozen_string_literal: true

class AddSlugToInterestGroup < ActiveRecord::Migration[5.2]

  def change
    add_column :gp_interest_groups, :slug, :string
  end

end
