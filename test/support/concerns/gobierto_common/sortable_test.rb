# frozen_string_literal: true

module GobiertoCommon::SortableTest
  def test_update_positions
    positions_from_params = { "0" => { "id" => sortable_object.id, "position" => 1 } }

    assert subject_class.update_positions(positions_from_params)
  end

  def test_reset_position!
    assert subject_class.reset_position!
  end
end
