class CreateGobiertoDataNeighbourhoods < ActiveRecord::Migration[6.0]
  def change
    create_table :gdata_neighbourhoods do |t|
      t.belongs_to  :site,    index: true
      t.belongs_to  :dataset, index: true
      t.string      :name
      t.json        :geometry
      t.timestamps
    end
  end
end
