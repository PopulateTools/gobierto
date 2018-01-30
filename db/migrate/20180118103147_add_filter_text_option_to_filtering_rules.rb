class AddFilterTextOptionToFilteringRules < ActiveRecord::Migration[5.1]
  def change
    add_column :gc_filtering_rules, :remove_filtering_text, :boolean, default: false
  end
end
