class AddConfigurationFlagsToGobiertoBudgetsConsultationsItems < ActiveRecord::Migration[5.0]
  def change
    add_column :gbc_consultation_items, :block_reduction, :boolean, default: false
  end
end
