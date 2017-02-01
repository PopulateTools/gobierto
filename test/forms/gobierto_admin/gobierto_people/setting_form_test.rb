require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class SettingFormTest < ActiveSupport::TestCase
      def valid_setting_form
        @valid_setting_form ||= SettingForm.new(
          id: setting.id,
          value: "new value"
        )
      end

      def setting
        @setting ||= gobierto_people_settings(:home_text)
      end

      def test_save_with_valid_attributes
        assert valid_setting_form.save
        setting.reload
        assert_equal "new value", setting.value
      end
    end
  end
end
