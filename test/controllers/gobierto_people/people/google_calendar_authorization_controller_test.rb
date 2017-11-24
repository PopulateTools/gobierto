# frozen_string_literal: true

require "test_helper"

class GobiertoPeople::People::GoogleCalendar::AuthorizationControllerTest < ActionController::TestCase
  def site
    @site ||= sites(:madrid)
  end

  def person
    @person ||= gobierto_people_people(:richard)
  end

  def test_new_request_without_code
    get :new, params: { token: person.google_calendar_token }
    assert_equal person.id, session[:google_calendar_person_id]
    assert_response :redirect
  end

  def test_new_request_with_code
    client_secrets = mock
    auth_client = mock

    client_secrets.stubs(to_authorization: auth_client)
    auth_client.stubs(update!: true, fetch_access_token!: true, to_json: "json")
    auth_client.stubs(:code=, true)
    auth_client.stubs(:client_secret=, true)
    Google::APIClient::ClientSecrets.stubs(:load).returns(client_secrets)

    get :new, params: { code: "foo" }, session: { google_calendar_person_id: person.id }
    assert_response :redirect

    configuration = GobiertoCalendars::GoogleCalendarConfiguration.find_by(collection: person.calendar)
    assert configuration.data["google_calendar_credentials"].present?
  end
end
