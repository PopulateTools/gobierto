# frozen_string_literal: true

class AddStatusesVocabularyIdToGplanPlans < ActiveRecord::Migration[5.2]
  def change
    add_reference :gplan_plans, :statuses_vocabulary
  end
end
