class AddInformationTextTranlsationsToProcess < ActiveRecord::Migration[5.1]

  def change
    add_column :gpart_processes, :information_text_translations, :jsonb
  end

end
