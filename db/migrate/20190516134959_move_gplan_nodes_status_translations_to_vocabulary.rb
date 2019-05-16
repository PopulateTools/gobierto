# frozen_string_literal: true

class MoveGplanNodesStatusTranslationsToVocabulary < ActiveRecord::Migration[5.2]
  def change
    add_reference :gplan_nodes, :status
  end
end
