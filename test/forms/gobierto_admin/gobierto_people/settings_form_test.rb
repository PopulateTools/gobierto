# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  module GobiertoPeople
    class SettingsFormTest < ActiveSupport::TestCase
      def valid_settings_form
        @valid_settings_form ||= SettingsForm.new(
          site_id: site.id,
          home_text_en: 'English text',
          submodules_enabled: ['blogs']
        )
      end

      def settings
        @gobierto_people_settings ||= gobierto_module_settings(:gobierto_people_settings_madrid)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_save_with_valid_attributes
        assert valid_settings_form.save
        assert_equal 'English text', valid_settings_form.gobierto_module_settings.home_text_en
      end
    end
  end
end
