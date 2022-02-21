# frozen_string_literal: true

module Integration
  module RequestsTrackingHelpers
    def with_requests_tracking_enabled
      ApplicationController.stub_any_instance(:ignore_tracking_request?, false) do
        yield
      end
    end
  end
end
