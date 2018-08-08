# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    class TermFormTest < ActiveSupport::TestCase
      def valid_term_form
        @valid_term_form ||= TermForm.new(
          site_id: site.id,
          name_translations: { I18n.locale => "test" },
          description_translations: { I18n.locale => "test description" },
          vocabulary_id: vocabulary.id,
          slug: nil
        )
      end

      def invalid_term_form
        @invalid_term_form ||= TermForm.new(
          site_id: nil,
          name_translations: nil,
          description_translations: nil,
          vocabulary_id: nil,
          slug: nil
        )
      end

      def term
        @term ||= gobierto_common_terms(:culture_term)
      end

      def site
        @site ||= sites(:madrid)
      end

      def vocabulary
        @vocabulary ||= gobierto_common_vocabularies(:animals)
      end

      def test_save_with_valid_attributes
        assert valid_term_form.save
      end

      def test_error_messages_with_invalid_attributes
        invalid_term_form.save

        assert_equal 1, invalid_term_form.errors.messages[:site].size
        assert_equal 1, invalid_term_form.errors.messages[:vocabulary].size
        assert_equal 1, invalid_term_form.errors.messages[:name_translations].size
      end
    end
  end
end
