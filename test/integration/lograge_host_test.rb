# frozen_string_literal: true

require "test_helper"

class LogrageHostTest < ActionDispatch::IntegrationTest
  def site
    @site ||= sites(:madrid)
  end

  # append_info_to_payload resolves the client address for every action. When
  # Client-IP and X-Forwarded-For contradict each other ActionDispatch raises,
  # and it raises from the ensure of process_action, discarding a response that
  # had already been rendered.
  def test_contradictory_client_address_headers_do_not_break_the_response
    with_current_site(site) do
      get gobierto_people_root_path, headers: { "HTTP_CLIENT_IP" => "198.51.100.7",
                                                "HTTP_X_FORWARDED_FOR" => "203.0.113.10" }

      assert_response :success
    end
  end

  def test_consistent_client_address_headers_are_accepted
    with_current_site(site) do
      get gobierto_people_root_path, headers: { "HTTP_CLIENT_IP" => "203.0.113.10",
                                                "HTTP_X_FORWARDED_FOR" => "203.0.113.10" }

      assert_response :success
    end
  end
end
