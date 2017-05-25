# frozen_string_literal: true

class FixContentBlockFieldsData < ActiveRecord::Migration[5.0]
  def change
    GobiertoCommon::ContentBlockField.where("name = ''").each do |cbf|
      next if cbf.name.present?
      cbf.name = SecureRandom.uuid
      cbf.save!
      puts " - Updated ContentBlockField #{cbf.id}"
    end
  end
end
