# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  class PlainCustomFieldValueDecoratorTest < ActiveSupport::TestCase
    def multiple_select_field
      @multiple_select_field ||= gobierto_common_custom_fields(:madrid_plans_custom_field_vocabulary_multiple_select)
    end

    def single_select_field
      @single_select_field ||= gobierto_common_custom_fields(:madrid_plans_custom_field_vocabulary_single_select)
    end

    def animals
      @animals ||= gobierto_common_vocabularies(:animals)
    end

    def dog
      @dog ||= gobierto_common_terms(:dog)
    end

    def cat
      @cat ||= gobierto_common_terms(:cat)
    end

    def table_field
      @table_field ||= CustomField.new(
        site: sites(:madrid),
        class_name: "GobiertoPlans::Node",
        field_type: :plugin,
        uid: "sub-actions",
        options: {
          configuration: {
            plugin_type: "table",
            plugin_configuration: { columns: [{ id: "date", type: "date" }, { id: "name", type: "text" }] }
          }
        }.deep_stringify_keys
      )
    end

    def decorated_value(custom_field, plain_text_value, allow_vocabulary_terms_creation: false)
      decorator = PlainCustomFieldValueDecorator.new(custom_field)
      decorator.allow_vocabulary_terms_creation = allow_vocabulary_terms_creation
      decorator.plain_text_value = plain_text_value
      I18n.with_locale(:en) { decorator.value }
    end

    def test_multiple_select_with_comma_separated_names
      assert_equal [dog.id.to_s, cat.id.to_s], decorated_value(multiple_select_field, "Dog, Cat")
    end

    def test_multiple_select_with_array_of_names
      assert_equal [dog.id.to_s, cat.id.to_s], decorated_value(multiple_select_field, ["Dog", " Cat "])
    end

    def test_multiple_select_with_array_of_external_ids
      assert_equal [dog.id.to_s, cat.id.to_s], decorated_value(multiple_select_field, %w(2 3))
    end

    def test_external_ids_match_ignoring_leading_zeros
      assert_equal [dog.id.to_s], decorated_value(multiple_select_field, %w(02))
    end

    def test_external_id_match_does_not_create_terms
      assert_no_difference "animals.terms.count" do
        assert_equal [dog.id.to_s], decorated_value(multiple_select_field, %w(2), allow_vocabulary_terms_creation: true)
      end
    end

    def test_name_match_takes_precedence_over_external_id
      term_named_like_an_external_id = animals.terms.create!(name_translations: { "en" => "3", "es" => "3" })

      assert_equal [term_named_like_an_external_id.id.to_s], decorated_value(multiple_select_field, %w(3))
    end

    def test_single_select_with_array
      assert_equal dog.id.to_s, decorated_value(single_select_field, %w(Dog))
    end

    def test_single_select_with_external_id
      assert_equal cat.id.to_s, decorated_value(single_select_field, "3")
    end

    def test_table_rows_keep_configured_columns_and_store_dates_in_iso_format
      rows = [
        { "date" => "13/11/2023", "name" => "First sub-action", "unknown" => "Ignored" },
        { "date" => "2025-06-02", "name" => "Second sub-action" },
        { "date" => "", "name" => nil }
      ]

      expected_rows = [
        { "date" => "2023-11-13", "name" => "First sub-action" },
        { "date" => "2025-06-02", "name" => "Second sub-action" },
        { "date" => nil, "name" => nil }
      ]
      assert_equal expected_rows, decorated_value(table_field, rows)
    end

    def test_table_with_invalid_date_raises
      error = assert_raises(PlainCustomFieldValueDecorator::InvalidValue) do
        decorated_value(table_field, [{ "date" => "not a date", "name" => "Sub-action" }])
      end

      assert_equal({ "value" => "not a date", "uid" => "sub-actions" }, JSON.parse(error.message))
    end

    def test_table_that_is_not_a_list_of_rows_raises
      assert_raises(PlainCustomFieldValueDecorator::InvalidValue) { decorated_value(table_field, "13/11/2023: Sub-action") }
      assert_raises(PlainCustomFieldValueDecorator::InvalidValue) { decorated_value(table_field, ["13/11/2023: Sub-action"]) }
    end

    def test_unknown_term_raises_when_creation_is_not_allowed
      assert_raises(PlainCustomFieldValueDecorator::TermNotFound) do
        decorated_value(multiple_select_field, %w(Unicorn))
      end
    end
  end
end
