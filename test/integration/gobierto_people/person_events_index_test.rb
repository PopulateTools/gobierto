require "test_helper"

module GobiertoPeople
  class PersonEventsIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_people_events_path
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_person_events_index
      with_current_site(site) do
        visit @path

        assert has_selector?("h3", text: "Upcoming events")
        assert has_selector?("h3", text: "Past events")
        assert has_selector?(".events-summary")
      end
    end
  end
end
