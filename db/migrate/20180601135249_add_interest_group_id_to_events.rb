class AddInterestGroupIdToEvents < ActiveRecord::Migration[5.2]
  def change
    add_reference :gc_events, :interest_group, index: true
  end
end
