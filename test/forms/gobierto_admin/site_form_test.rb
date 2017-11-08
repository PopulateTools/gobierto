# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class SiteFormTest < ActiveSupport::TestCase
    def valid_site_form
      @valid_site_form ||= SiteForm.new(
        title_translations: { I18n.locale => site.title },
        name_translations: { I18n.locale => new_site_name }, # To ensure uniqueness
        domain: new_site_domain, # To ensure uniqueness
        location_name: site.location_name,
        municipality_id: 1,
        visibility_level: "active",
        default_locale: "es",
        available_locales: %w(es ca),
        privacy_page_id: privacy_page.id,
        home_page: "GobiertoParticipation"
      )
    end

    def invalid_site_form
      @invalid_site_form ||= SiteForm.new(
        title_translations: {},
        name_translations: {},
        domain: site.domain,
        location_name: site.location_name,
        visibility_level: "active",
        default_locale: nil,
        available_locales: []
      )
    end

    def valid_google_analytics_id_site_form
      @valid_google_analytics_id_site_form ||= SiteForm.new(
        valid_site_form.instance_values.merge(google_analytics_id: "UA-000000-01")
      )
    end

    def invalid_google_analytics_id_site_form
      @invalid_google_analytics_id_site_form ||= SiteForm.new(
        valid_site_form.instance_values.merge(google_analytics_id: "UA-WADUS")
      )
    end

    def site
      @site ||= sites(:madrid)
    end

    def privacy_page
      @privacy_page ||= gobierto_cms_pages(:privacy)
    end

    def new_site_name
      "Wadus"
    end

    def new_site_domain
      "wadus.gobierto.dev"
    end

    def test_validation
      assert valid_site_form.valid?
    end

    def test_google_analytics_id_validation
      assert valid_google_analytics_id_site_form.valid?
      refute invalid_google_analytics_id_site_form.valid?
    end

    def test_save_with_valid_attributes
      assert valid_site_form.save
    end

    def test_error_messages_with_invalid_attributes
      invalid_site_form.save

      assert invalid_site_form.errors.messages[:title_translations].one?
      assert invalid_site_form.errors.messages[:name_translations].one?
      assert invalid_site_form.errors.messages[:available_locales].one?
    end
  end
end
