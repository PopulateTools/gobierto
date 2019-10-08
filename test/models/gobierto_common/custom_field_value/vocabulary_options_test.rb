# frozen_string_literal: true

require "test_helper"

module GobiertoCommon::CustomFieldValue
  class VocabularyOptionsTest < ActiveSupport::TestCase

    def single_select_record
      @single_select_record ||= gobierto_common_custom_field_records(
        :political_agendas_custom_field_record_vocabulary_single_select
      )
    end

    def multiple_select_record
      @multiple_select_record ||= gobierto_common_custom_field_records(
        :political_agendas_custom_field_record_vocabulary_multiple_select
      )
    end

    def multiple_tags_select_record
      @multiple_tags_select_record ||= gobierto_common_custom_field_records(
        :political_agendas_custom_field_record_vocabulary_tags
      )
    end

    def mammal_term
      gobierto_common_terms(:mammal)
    end

    def dog_term
      gobierto_common_terms(:dog)
    end

    def vocabulary_term
      gobierto_common_terms(:cat)
    end

    def other_vocabulary_term
      gobierto_common_terms(:marvel_term)
    end

    def test_vocabulary_single_select_value_string
      assert_equal [mammal_term.name], single_select_record.value_string
    end

    def test_vocabulary_multiple_select_value_string
      assert_equal [mammal_term.name, dog_term.name], multiple_select_record.value_string
    end

    def test_vocabulary_tags_value_string
      assert_equal [mammal_term.name, dog_term.name], multiple_tags_select_record.value_string
    end

    def test_vocabulary_single_select_filter_value
      assert_equal mammal_term.id.to_s, single_select_record.filter_value
    end

    def test_vocabulary_multiple_select_filter_value
      assert_equal [mammal_term.id.to_s, dog_term.id.to_s].to_s, multiple_select_record.filter_value
    end

    def test_vocabulary_tags_filter_value
      assert_equal [mammal_term.id.to_s, dog_term.id.to_s].to_s, multiple_tags_select_record.filter_value
    end

    def test_vocabulary_single_select_value_assign_with_vocabulary_term
      single_select_record.value = vocabulary_term

      assert_equal [vocabulary_term.name], single_select_record.value_string
      assert_equal vocabulary_term.id.to_s, single_select_record.filter_value
    end

    def test_vocabulary_single_select_value_assign_with_other_vocabulary_term
      single_select_record.value = other_vocabulary_term

      assert_equal [], single_select_record.value_string
      refute_equal other_vocabulary_term.id.to_s, single_select_record.filter_value
    end

    def test_vocabulary_single_select_value_assign_with_term_integer_id
      single_select_record.value = vocabulary_term.id

      assert_equal [vocabulary_term.name], single_select_record.value_string
      assert_equal vocabulary_term.id.to_s, single_select_record.filter_value
    end

    def test_vocabulary_single_select_value_assign_with_other_vocabulary_integer_id
      single_select_record.value = other_vocabulary_term.id

      assert_equal [], single_select_record.value_string
      refute_equal other_vocabulary_term.id.to_s, single_select_record.filter_value
    end

    def test_vocabulary_single_select_value_assign_with_term_string_id
      single_select_record.value = vocabulary_term.id.to_s

      assert_equal [vocabulary_term.name], single_select_record.value_string
      assert_equal vocabulary_term.id.to_s, single_select_record.filter_value
    end

    def test_vocabulary_single_select_value_assign_with_other_vocabulary_string_id
      single_select_record.value = other_vocabulary_term.id.to_s

      assert_equal [], single_select_record.value_string
      refute_equal other_vocabulary_term.id.to_s, single_select_record.filter_value
    end

    def test_vocabulary_single_select_value_assign_with_array_of_integer_ids
      single_select_record.value = [vocabulary_term.id, mammal_term.id]

      assert_equal [vocabulary_term.name], single_select_record.value_string
      assert_equal vocabulary_term.id.to_s, single_select_record.filter_value
    end

    def test_vocabulary_single_select_value_assign_with_array_of_string_ids
      single_select_record.value = [vocabulary_term.id.to_s, mammal_term.id.to_s]

      assert_equal [vocabulary_term.name], single_select_record.value_string
      assert_equal vocabulary_term.id.to_s, single_select_record.filter_value
    end

  end
end
