require "test_helper"

class Admin::SitesControllerTest < ActionController::TestCase
  def setup
    super
    @notification_service_spy = Spy.on(Publishers::SiteActivity, :broadcast_event)
  end

  attr_reader :notification_service_spy

  def admin
    @admin ||= admins(:tony)
  end

  def site
    @site ||= sites(:madrid)
  end

  def admin_session
    @admin_session ||= { admin_id: admin.id }
  end

  def first_call_arguments
    notification_service_spy.calls.first.args
  end

  def test_create_site_broadcasts_event
    post :create, params: { site: { title: 'Title', name: 'Foo', location_name: 'Madrid', domain: 'test2.gobierto.dev' } },  session: admin_session
    assert_response :redirect

    assert notification_service_spy.has_been_called?
    event_name, event_payload = first_call_arguments
    assert_equal "site_created", event_name
    assert_includes event_payload, :ip
    assert_equal event_payload[:author], admin
    assert_kind_of Site, event_payload[:subject]
  end

  def test_update_site_broadcasts_event
    patch :update, params: { id: site.id, site: { title: 'Title', name: 'Foo', location_name: 'Madrid', domain: 'test2.gobierto.dev' } },  session: admin_session
    assert_response :redirect

    assert notification_service_spy.has_been_called?
    event_name, event_payload = first_call_arguments
    assert_equal "site_updated", event_name
    assert_includes event_payload, :ip
    assert_equal event_payload[:author], admin
    assert_equal event_payload[:subject], site
    assert event_payload.include?(:changes)
  end

  def test_update_site_with_invalid_params_doesnt_broadcasts_event
    patch :update, params: { id: site.id, site: { name: '' } },  session: admin_session
    assert_response :success

    refute notification_service_spy.has_been_called?
  end

  def test_destroy_site_broadcasts_event
    delete :destroy, params: { id: site.id },  session: admin_session
    assert_response :redirect

    assert notification_service_spy.has_been_called?
    event_name, event_payload = first_call_arguments
    assert_equal "site_deleted", event_name
    assert_includes event_payload, :ip
    assert_equal event_payload[:author], admin
    assert_equal event_payload[:subject], site
  end
end
