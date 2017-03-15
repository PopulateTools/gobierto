require "test_helper"

module GobiertoPeople
  class PersonEventsIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_people_events_path
      @path_for_json = gobierto_people_events_path(format: :json)
      @path_for_csv = gobierto_people_events_path(format: :csv)
    end

    def site
      @site ||= sites(:madrid)
    end

    def upcoming_events
      @upcoming_events ||= [
        gobierto_people_person_events(:richard_published)
      ]
    end

    def upcoming_event
      @upcoming_event ||= upcoming_events.first
    end

    def people
      @people ||= [
        gobierto_people_people(:richard),
        gobierto_people_people(:tamara)
      ]
    end

    def political_groups
      @political_groups ||= [
        gobierto_people_political_groups(:marvel),
        gobierto_people_political_groups(:dc)
      ]
    end

    def test_person_events_index
      with_current_site(site) do
        visit @path

        assert has_selector?("h2", text: "#{site.name}'s member agendas")
      end
    end

    def test_person_events_filter
      with_current_site(site) do
        visit @path

        within ".filter_boxed" do
          assert has_link?("Government Team")
          assert has_link?("Opposition")
          assert has_link?("Executive")
          assert has_link?("All")
        end
      end
    end

    def test_events_summary
      with_current_site(site) do
        visit @path

        within ".events-summary" do
          assert has_content?("Agenda")
          assert has_link?("Past events")

          upcoming_events.each do |event|
            assert has_selector?(".person_event-item", text: event.title)
            assert has_link?(event.title)
          end
        end
      end
    end

    def test_calendar_component
      with_current_site(site) do
        visit gobierto_people_events_path(start_date: upcoming_event.starts_at)

        within ".calendar-component" do
          assert has_link?(upcoming_event.starts_at.day)
        end
      end
    end

    def test_agenda_switcher
      with_current_site(site) do
        visit @path

        within ".agenda-switcher" do
          people.each do |person|
            assert has_link?(person.name)
          end
        end
      end
    end

    def test_subscription_block
      with_current_site(site) do
        visit @path

        within ".subscribable-box", match: :first do
          assert has_button?("Subscribe")
        end
      end
    end

    def test_person_events_index_json
      with_current_site(site) do
        get @path_for_json

        json_response = JSON.parse(response.body)
        assert_equal json_response.first["person_name"], "Richard Rider"
        assert_equal json_response.first["title"], "Junta de Gobierno"
        assert_equal json_response.first["description"], "El Presidente analizará la marcha de las medidas adoptadas en los primeros días de Gobierno."
      end
    end

    def test_person_events_index_csv
      with_current_site(site) do
        get @path_for_csv

        csv_response = CSV.parse(response.body, headers: true)
        assert_equal csv_response.by_row[0]["person_name"], "Richard Rider"
        assert_equal csv_response.by_row[0]["title"], "Junta de Gobierno"
        assert_equal csv_response.by_row[0]["description"], "El Presidente analizará la marcha de las medidas adoptadas en los primeros días de Gobierno."
      end
    end
  end
end
