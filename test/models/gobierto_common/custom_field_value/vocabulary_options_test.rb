# frozen_string_literal: true

require "test_helper"

module GobiertoCommon::CustomFieldValue
  class VocabularyOptionsTest < ActiveSupport::TestCase

    def test_vocabulary_single_select_value_string
      record = gobierto_common_custom_field_records(
        :political_agendas_custom_field_record_vocabulary_single_select
      )

      assert_equal ["Mammal"], record.value_string
    end

    def test_vocabulary_multiple_select_value_string
      record = gobierto_common_custom_field_records(
        :political_agendas_custom_field_record_vocabulary_multiple_select
      )

      assert_equal %w(Mammal Dog), record.value_string
    end

    def test_vocabulary_tags_value_string
      record = gobierto_common_custom_field_records(
        :political_agendas_custom_field_record_vocabulary_tags
      )

      assert_equal %w(Mammal Dog), record.value_string
    end

  end
end
