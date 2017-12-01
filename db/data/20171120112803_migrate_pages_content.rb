class MigratePagesContent < ActiveRecord::Migration[5.1]
  def up
    GobiertoCms::Page.all.each do |page|
      page.body_source_translations = page.body_translations
      page.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
