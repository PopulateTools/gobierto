require "test_helper"

class GobiertoCommon::LocalizedContentTest < ActiveSupport::TestCase
  def subject
    @subject ||= sites(:madrid)
  end

  def test_localized_with_fallback
    I18n.locale = :ca
    assert_nil subject.title
    assert_equal "Transparencia y Participción", subject.title_with_fallback
  end

  def test_localized_with_fallback_priorizes_current_locale
    subject.title_translations = { 'en' => 'Transparency', 'es' => 'Transparencia y Participción' }
    I18n.locale = :es
    assert_equal "Transparencia y Participción", subject.title
    assert_equal "Transparencia y Participción", subject.title_with_fallback
  end

  def test_localized_with_fallback_empty_attribute
    site = Site.new
    assert_nil site.title_with_fallback
  end

end
