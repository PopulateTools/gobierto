# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    class ScopeFormTest < ActiveSupport::TestCase
      def valid_scope_form
        @valid_scope_form ||= ScopeForm.new(
          site_id: site.id,
          name_translations: { I18n.locale => scope.name },
          description_translations: { I18n.locale => scope.description },
          slug: nil
        )
      end

      def invalid_scope_form
        @invalid_scope_form ||= ScopeForm.new(
          site_id: nil,
          name_translations: { I18n.locale => scope.name },
          description_translations: nil,
          slug: nil
        )
      end

      def scope
        @scope ||= gobierto_common_terms(:center_term)
      end

      def site
        @site ||= sites(:santander)
      end

      def test_save_with_valid_attributes
        assert valid_scope_form.save
      end

      def test_error_messages_with_invalid_attributes
        invalid_scope_form.save

        assert_equal 1, invalid_scope_form.errors.messages[:site].size
      end
    end
  end
end
