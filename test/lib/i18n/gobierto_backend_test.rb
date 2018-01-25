# frozen_string_literal: true

require "test_helper"

class GobiertoBackendTest < ActiveSupport::TestCase
  def site
    @site ||= sites(:madrid)
  end

  def other_site
    @other_site ||= sites(:huesca)
  end

  def key
    @key ||= "activerecord.errors.messages.record_invalid"
  end

  def locale
    @locale ||= I18n.locale
  end

  def teardown
    Translation.destroy_all
    reset_translations_cache
  end

  def reset_translations_cache
    I18n.backend.reload!
    I18n::Backend::Gobierto::Translation.reset_cached_entries!
  end

  def test_site_entry
    with_current_site(site) do
      Translation.create! site_id: other_site.id, locale: locale, key: key, value: "Huesca translation"
      Translation.create! site_id: site.id, locale: locale, key: key, value: "Custom site translation"
      Translation.create! locale: locale, key: key, value: "Custom global translation"

      reset_translations_cache

      assert_equal "Custom site translation", I18n.t(key)
    end
  end

  def test_global_entry
    with_current_site(site) do
      Translation.create! locale: locale, key: key, value: "Custom global translation"

      reset_translations_cache

      assert_equal "Custom global translation", I18n.t(key)
    end
  end

  def test_missing_entry_fallbacks_to_simple_backend
    with_current_site(site) do
      reset_translations_cache

      assert_equal "Validation failed: %{errors}",  I18n.t(key)
    end
  end
end
