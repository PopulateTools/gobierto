# frozen_string_literal: true

require "test_helper"

module GobiertoCommon::CustomFieldValue
  class VocabularyOptionsTest < ActiveSupport::TestCase

    def test_vocabulary_single_select_value
      record = gobierto_common_custom_field_records(
        :political_agendas_custom_field_record_vocabulary_single_select
      )

      assert_equal ["Mammal"], record.value
    end

    def test_vocabulary_multiple_select_value
      record = gobierto_common_custom_field_records(
        :political_agendas_custom_field_record_vocabulary_multiple_select
      )

      assert_equal %w(Mammal Dog), record.value
    end

    def test_vocabulary_tags_value
      record = gobierto_common_custom_field_records(
        :political_agendas_custom_field_record_vocabulary_tags
      )

      assert_equal %w(Mammal Dog), record.value
    end

  end
end
