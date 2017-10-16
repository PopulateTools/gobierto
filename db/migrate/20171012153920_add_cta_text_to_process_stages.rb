class AddCtaTextToProcessStages < ActiveRecord::Migration[5.1]

  def change
    add_column :gpart_process_stages, :cta_text_translations, :jsonb
  end

end
