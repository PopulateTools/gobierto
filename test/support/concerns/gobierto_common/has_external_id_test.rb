# frozen_string_literal: true

module GobiertoCommon::HasExternalIdTest

  def test_automatic_generation_of_external_id_when_table_is_empty
    subject.destroy_all

    new_item = subject.new
    new_item.valid?

    assert_equal "1", new_item.external_id
  end

  def test_automatic_generation_of_external_id_when_there_are_items
    existing_item = subject.first
    subject.where.not(id: existing_item.id).destroy_all

    new_item = subject.new
    new_item.valid?

    refute_equal existing_item.external_id, new_item.external_id
  end
end
