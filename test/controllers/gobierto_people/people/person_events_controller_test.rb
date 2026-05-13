# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  module People
    class PersonEventsControllerTest < GobiertoControllerTest

      def site
        @site ||= sites(:madrid)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      # Regression for https://github.com/PopulateTools/issues/issues/2150.
      # When respond_to lists format.js before format.html, requests with
      # Accept: */* (curl, bots) render index.js.erb but caches_action keys
      # the response by request.format (still :html for */*), so the JS
      # body gets cached at the HTML key and served back to every browser.
      def test_wildcard_accept_does_not_render_js_for_html_cache
        with(site: site) do
          Rails.application.config.action_controller.stubs(:perform_caching).returns(true)

          get gobierto_people_person_events_path(person.slug), headers: { "Accept" => "*/*" }

          assert_response :success
          assert_equal "text/html", response.media_type
          refute response.body.lstrip.start_with?("$('.see_more')"),
                 "Wildcard Accept response leaked JS body: #{response.body[0, 200].inspect}"
        end
      end

      def test_browser_request_after_wildcard_returns_html
        with(site: site) do
          Rails.application.config.action_controller.stubs(:perform_caching).returns(true)

          get gobierto_people_person_events_path(person.slug), headers: { "Accept" => "*/*" }
          assert_response :success

          get gobierto_people_person_events_path(person.slug),
              headers: { "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" }

          assert_response :success
          assert_equal "text/html", response.media_type
          refute response.body.lstrip.start_with?("$('.see_more')"),
                 "Browser hit on cached entry returned JS body: #{response.body[0, 200].inspect}"
        end
      end

    end
  end
end
