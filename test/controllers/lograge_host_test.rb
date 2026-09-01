# frozen_string_literal: true

require "test_helper"

class LogrageHostTest < ActiveSupport::TestCase
  # ActionDispatch::RemoteIp leaves the address unresolved for the rest of the
  # stack to calculate, so the payload is built from a request annotated the
  # same way the middleware annotates it.
  def payload_for(headers)
    env = Rack::MockRequest.env_for("/", { "REMOTE_ADDR" => "172.17.0.1" }.merge(headers))
    request = ActionDispatch::Request.new(env)
    request.remote_ip = ActionDispatch::RemoteIp::GetIp.new(request, true, ActionDispatch::RemoteIp::TRUSTED_PROXIES)

    controller = ApplicationController.new
    controller.set_request!(request)

    {}.tap { |payload| controller.send(:append_info_to_payload, payload) }
  end

  # Both headers are supplied by the client, and append_info_to_payload runs in
  # the ensure of process_action: a raise escaping from here turns a response
  # that was already rendered into a 500.
  def test_contradictory_client_address_headers_leave_the_remote_ip_unset
    payload = payload_for("HTTP_CLIENT_IP" => "198.51.100.7", "HTTP_X_FORWARDED_FOR" => "203.0.113.10")

    assert_nil payload[:remote_ip]
    assert_equal "203.0.113.10", payload[:x_forwarded_for]
  end

  def test_consistent_client_address_headers_are_recorded
    payload = payload_for("HTTP_CLIENT_IP" => "203.0.113.10", "HTTP_X_FORWARDED_FOR" => "203.0.113.10")

    assert_equal "203.0.113.10", payload[:remote_ip]
  end
end
