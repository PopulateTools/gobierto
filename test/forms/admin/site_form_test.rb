require "test_helper"

class Admin::SiteFormTest < ActiveSupport::TestCase
  def valid_site_form
    @valid_site_form ||= Admin::SiteForm.new(
      title: site.title,
      name: new_site_name, # To ensure uniqueness
      domain: new_site_domain, # To ensure uniqueness
      location_name: site.location_name,
      visibility_level: "active"
    )
  end

  def invalid_site_form
    @invalid_site_form ||= Admin::SiteForm.new(
      title: nil,
      name: nil,
      domain: site.domain,
      location_name: site.location_name,
      visibility_level: "active"
    )
  end

  def valid_google_analytics_id_site_form
    @valid_google_analytics_id_site_form ||= Admin::SiteForm.new(
      google_analytics_id: "UA-000000-01",
      visibility_level: "active"
    )
  end

  def invalid_google_analytics_id_site_form
    @invalid_google_analytics_id_site_form ||= Admin::SiteForm.new(
      google_analytics_id: "UA-WADUS",
      visibility_level: "active"
    )
  end

  def site
    @site ||= sites(:madrid)
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

    assert invalid_site_form.errors.messages[:title].one?
    assert invalid_site_form.errors.messages[:name].one?
  end
end
