# frozen_string_literal: true

require "test_helper"

class HomePageTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = root_path
  end

  def site
    @site ||= sites(:madrid)
  end

  def faq_page
    @faq_page ||= gobierto_cms_pages(:consultation_faq)
  end

  def privacy_page
    @privacy_page ||= gobierto_cms_pages(:privacy)
  end

  def test_greeting_to_first_active_module
    with_current_site(site) do
      visit @path

      assert has_content?("Richard Rider")
    end
  end

  def test_greeting_when_cms_is_main_module
    site.configuration.home_page = "GobiertoCms"
    site.configuration.home_page_item_id = faq_page.to_global_id
    site.save!

    with_current_site(site) do
      visit @path

      assert has_content?("Consultation page FAQ")
    end
  end

  def test_privacy_page
    with_current_site(site) do
      visit @path

      assert has_no_link?("By signing up you agree to the Privacy Policy")
    end
  end
end
