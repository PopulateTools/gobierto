class RemoveModuleBudgetConsultations < ActiveRecord::Migration[6.0]
  def up
    drop_table :gbc_consultation_responses
    drop_table :gbc_consultation_items
    drop_table :gbc_consultations

    Site.all.each do |s|
      s.configuration_data["modules"].delete("GobiertoBudgetsConsultation")
      s.configuration_data["modules"].first if s.configuration_data["home_page"] == "GobiertoBudgetsConsultation"
      s.save
    end
  end

  def down
  end
end
