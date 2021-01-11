# frozen_string_literal: true

require "test_helper"

class GobiertoPeople::PeopleeControllerTest < GobiertoControllerTest

  def setup
    %w(agendas gifts invitations trips).each do |submodule|
      enable_submodule(site, submodule)
    end
    super
  end

  def site
    @site_with_module_enabled ||= sites(:madrid)
  end

  def person
    @person ||= gobierto_people_people(:richard)
  end

  def set_default_dates(options = {})
    conf = site.configuration
    conf.raw_configuration_variables = <<-YAML
gobierto_people_default_filter_start_date: "#{options[:start_date]}"
gobierto_people_default_filter_end_date: "#{options[:end_date]}"
    YAML
    site.save
  end

  def wide_date_range_params
    @wide_date_range_params ||= { start_date: 10.years.ago.strftime("%Y-%m-%d"), end_date: 10.years.from_now.strftime("%Y-%m-%d") }
  end

  def test_wrong_dates_cause_bad_request
    with_current_site(site) do
      get gobierto_people_past_events_path(date: '2018-04-27', start_date: '700')
      assert_response :bad_request
    end
  end

  def test_redirect_without_default_dates
    with_current_site(site) do
      get gobierto_people_person_path(person.slug)
      assert_response :success

      person.events.destroy_all
      person.received_gifts.destroy_all
      person.invitations.destroy_all

      get gobierto_people_person_path(person.slug)
      assert_response :success

      person.trips.destroy_all

      get gobierto_people_person_path(person.slug)
      assert_response :success
    end
  end

  def test_redirect_with_default_dates
    with_current_site(site) do
      set_default_dates(wide_date_range_params)
      get gobierto_people_person_path(person.slug)
      assert_response :success
    end
  end

  def test_redirect_with_default_dates_and_person_path
    with_current_site(site) do
      set_default_dates(wide_date_range_params)

      person.events.destroy_all
      person.invitations.destroy_all
      person.trips.destroy_all

      get gobierto_people_person_path(person.slug)
      assert_response :redirect
      assert_redirected_to(gobierto_people_person_gifts_path(@person.slug))
    end
  end

  def test_redirect_with_default_dates_and_person_path_with_ranges
    with_current_site(site) do
      set_default_dates(wide_date_range_params)

      person.events.destroy_all
      person.invitations.destroy_all
      person.trips.destroy_all

      last_year = Date.today.year - 1
      get gobierto_people_person_path(person.slug, start_date: "2012-01-01", end_date: "#{last_year}-01-01")
      assert_response :redirect
      assert_redirected_to(gobierto_people_person_gifts_path(@person.slug, start_date: "2012-01-01", end_date: "#{last_year}-01-01"))
    end
  end
end
