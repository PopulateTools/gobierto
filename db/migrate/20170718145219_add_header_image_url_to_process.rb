class AddHeaderImageUrlToProcess < ActiveRecord::Migration[5.1]
  
  def change
    add_column :gpart_processes, :header_image_url, :string
  end

end
