# frozen_string_literal: true

require "test_helper"

class GobiertoCommon::CustomFieldTest < ActiveSupport::TestCase

  def single_option_custom_field
    @single_option_custom_field ||= gobierto_common_custom_fields(:madrid_custom_field_country)
  end

  def vocabulary_custom_field
    @vocabulary_custom_field ||= gobierto_common_custom_fields(:madrid_plans_custom_field_vocabulary_single_select)
  end

  def plugin_custom_field
    @plugin_custom_field ||= gobierto_common_custom_fields(:madrid_custom_field_table_plugin)
  end

  def animals_vocabulary
    @animals_vocabulary ||= gobierto_common_vocabularies(:animals)
  end

  def issues_vocabulary
    @issues_vocabulary ||= gobierto_common_vocabularies(:issues_vocabulary)
  end

  def plugin_custom_field_with_vocabularies(vocabulary_ids)
    plugin_custom_field.tap do |custom_field|
      custom_field.options["configuration"]["plugin_configuration"]["vocabulary_ids"] = vocabulary_ids
    end
  end

  def subject
    @subject ||= gobierto_common_custom_fields(:madrid_custom_field_country)
  end

  def test_valid
    assert subject.valid?
  end

  def test_has_vocabulary?
    refute single_option_custom_field.has_vocabulary?
  end

  def test_has_vocabulary_with_vocabulary_field_type
    assert vocabulary_custom_field.has_vocabulary?
  end

  def test_has_vocabulary_with_plugin_not_requiring_vocabulary
    refute plugin_custom_field.has_vocabulary?
  end

  def test_has_vocabulary_with_vocabularies_configured_in_plugin
    assert plugin_custom_field_with_vocabularies([animals_vocabulary.id]).has_vocabulary?
  end

  def test_requires_vocabulary_does_not_depend_on_configured_vocabularies
    refute plugin_custom_field_with_vocabularies([animals_vocabulary.id]).requires_vocabulary?
    assert vocabulary_custom_field.requires_vocabulary?
    refute single_option_custom_field.requires_vocabulary?
  end

  def test_vocabulary_ids_is_always_an_array
    assert_equal [], single_option_custom_field.vocabulary_ids
    assert_equal [], plugin_custom_field.vocabulary_ids
    assert_equal [], vocabulary_custom_field.vocabulary_ids
  end

  def test_vocabulary_ids_with_vocabularies_configured_in_plugin
    custom_field = plugin_custom_field_with_vocabularies([animals_vocabulary.id, issues_vocabulary.id])

    assert_equal [animals_vocabulary.id, issues_vocabulary.id], custom_field.vocabulary_ids
  end

  def test_vocabulary
    assert_equal animals_vocabulary, vocabulary_custom_field.vocabulary
    assert_nil single_option_custom_field.vocabulary
  end

  def test_vocabularies_includes_single_and_configured_vocabularies
    assert_equal [animals_vocabulary], vocabulary_custom_field.vocabularies.to_a
    assert_empty plugin_custom_field.vocabularies

    custom_field = plugin_custom_field_with_vocabularies([animals_vocabulary.id, issues_vocabulary.id])

    assert_equal [animals_vocabulary, issues_vocabulary].sort_by(&:id),
                 custom_field.vocabularies.sort_by(&:id)
  end

end
