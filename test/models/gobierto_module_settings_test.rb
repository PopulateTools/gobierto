# frozen_string_literal: true

require 'test_helper'

class GobiertoModuleSettingsTest < ActiveSupport::TestCase
  def gobierto_people_settings
    @gobierto_people_settings ||= gobierto_module_settings(:gobierto_people_settings_madrid)
  end

  def test_dynamic_setters
    module_settings = GobiertoModuleSettings.new
    module_settings.first_setting = 'foo'
    module_settings.second_setting = 'bar'

    assert_equal 'foo', module_settings.settings['first_setting']
    assert_equal 'bar', module_settings.settings['second_setting']
  end

  def test_update
    assert_equal 'Home text English', gobierto_people_settings.home_text_en
    gobierto_people_settings.home_text_en = 'Home text English updated'
    gobierto_people_settings.save!
    gobierto_people_settings.reload
    assert_equal 'Home text English updated', gobierto_people_settings.home_text_en
  end

  def test_dynamic_getters
    assert_equal 'Home text English', gobierto_people_settings.home_text_en
    assert_nil gobierto_people_settings.wrong_field
  end
end
