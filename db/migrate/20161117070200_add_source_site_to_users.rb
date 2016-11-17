class AddSourceSiteToUsers < ActiveRecord::Migration[5.0]
  def change
    add_reference :users, :source_site
  end
end
