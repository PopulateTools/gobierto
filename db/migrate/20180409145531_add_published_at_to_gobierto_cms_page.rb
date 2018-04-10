class AddPublishedAtToGobiertoCmsPage < ActiveRecord::Migration[5.2]

  def up
    add_column :gcms_pages, :published_on, :datetime

    GobiertoCms::Page.unscoped.each do |page|
      page.update_attributes!(published_on: page.created_at)
    end

    change_column :gcms_pages, :published_on, :datetime, null: false
  end

  def down
    remove_column :gcms_pages, :published_on
  end

end
