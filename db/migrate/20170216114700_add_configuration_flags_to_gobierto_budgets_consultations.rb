class AddConfigurationFlagsToGobiertoBudgetsConsultations < ActiveRecord::Migration[5.0]
  def change
    add_column :gbc_consultations, :show_figures, :boolean, default: true
    add_column :gbc_consultations, :force_responses_balance, :boolean, default: false
  end
end
