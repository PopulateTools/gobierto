class FixContentBlockFieldsData < ActiveRecord::Migration[5.0]
  def change
    GobiertoCommon::ContentBlockField.where("name = ''").each do |cbf|
      if cbf.name.blank?
        cbf.name = SecureRandom.uuid
        cbf.save!
        puts " - Updated ContentBlockField #{cbf.id}"
      end
    end
  end
end
