# frozen_string_literal: true

require 'test_helper'
require 'support/file_uploader_helpers'

module GobiertoAdmin
  class SiteHtmlTemplatesTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = edit_admin_site_path(site)
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def site
      @site ||= sites(:madrid)
    end

    def privacy_page
      @privacy_page ||= gobierto_cms_pages(:privacy)
    end

    def template
      %(<a href="{% page_url #{privacy_page.slug} %}">{% page_title #{privacy_page.slug} %}</a>)
    end

    def test_site_render_liquid_html_blocks
      site.configuration.head_markup = template
      site.configuration.foot_markup = template
      site.save!

      with_current_site(site) do
        visit root_path
        assert has_link?('Privacy')
      end
    end
  end
end
