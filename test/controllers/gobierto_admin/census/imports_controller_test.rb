# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class Census::ImportsControllerTest < GobiertoControllerTest
    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def setup
      super
      @notification_service_spy = Spy.on(Publishers::CensusActivity, :broadcast_event)
      sign_in_admin(admin)
    end

    attr_reader :notification_service_spy

    def first_call_arguments
      notification_service_spy.calls.first.args
    end

    def teardown
      super
      sign_out_admin
    end

    def valid_census_params
      {
        census_import: {
          file: Rack::Test::UploadedFile.new(Rails.root.join("test/fixtures/files/census.csv"))
        }
      }
    end

    def test_create
      post admin_census_imports_url, params: valid_census_params
      assert_response :redirect
    end

    def test_create_broadcast_event
      post admin_census_imports_url, params: valid_census_params
      assert_response :redirect

      assert notification_service_spy.has_been_called?
      event_name, event_payload = first_call_arguments
      assert_equal "census_imported", event_name
      assert_includes event_payload, :ip
      assert_equal event_payload[:author], admin
      assert_equal event_payload[:subject], GobiertoAdmin::CensusImport.last
      refute event_payload.include?(:changes)
    end
  end
end
