# frozen_string_literal: true

class CopyProcessBodyToBodySource < ActiveRecord::Migration[5.2]
  def change
    ::GobiertoParticipation::Process.all.each do |process|
      process.body_source_translations = process.body_translations
      process.save!
    end
  end
end
