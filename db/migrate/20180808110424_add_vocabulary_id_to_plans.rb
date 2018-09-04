# frozen_string_literal: true

class AddVocabularyIdToPlans < ActiveRecord::Migration[5.2]
  def change
    add_reference :gplan_plans, :vocabulary, index: true
  end
end
