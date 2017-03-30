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

    def government_member
      gobierto_people_people(:richard)
    end

    def executive_member
      gobierto_people_people(:tamara)
    end

    def people
      @people ||= [government_member, executive_member]
    end

    def political_groups
      @political_groups ||= [
        gobierto_people_political_groups(:marvel),
        gobierto_people_political_groups(:dc)
      ]
    end

    def upcoming_events
      @upcoming_events ||= [
        gobierto_people_person_events(:richard_published)
      ]
    end

    def upcoming_event
      @upcoming_event ||= upcoming_events.first
    end

    def create_event(options = {})
      GobiertoPeople::PersonEvent.create!(
        person: options[:person] || government_member,
        title: "Event title",
        description: "Event description",
        starts_at: Time.zone.parse(options[:starts_at]) || Time.zone.now,
        ends_at: (Time.zone.parse(options[:starts_at]) || Time.zone.now) + 1.hour,
        state: GobiertoPeople::PersonEvent.states["published"]
      )
    end

    def create_events_for_dates(dates)
      @visible_month_events ||= dates.map do |date|
        create_event(starts_at: date)
      end
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
      upcoming_event = create_events_for_dates(["2017-03-15 16:00"]).first

      Timecop.freeze(Time.zone.parse("2017-03-15 16:00")) do
        with_current_site(site) do
          visit gobierto_people_events_path(start_date: upcoming_event.starts_at)

          within ".calendar-component" do
            assert has_link?(upcoming_event.starts_at.day)
          end
        end
      end
    end

    def test_calendar_navigation_arrows
      visible_month_events = create_events_for_dates(["2017-02-15 16:00", "2017-04-15 16:00"])

      Timecop.freeze(Time.zone.parse("2017-03-15 16:00")) do

        with_current_site(site) do
          visit gobierto_people_events_path

          within ".calendar-heading" do
            click_link "next-month-link"
          end

          within ".calendar-component" do
            assert has_link?(visible_month_events.last.starts_at.day)
          end

          visit gobierto_people_events_path

          within ".calendar-heading" do
            click_link "previous-month-link"
          end

          within ".calendar-component" do
            assert has_link?(visible_month_events.first.starts_at.day)
          end
        end

      end
    end

    def test_calendar_event_links
      visible_month_events = create_events_for_dates(["2017-02-28 16:00", "2017-03-14 16:00", "2017-03-16 16:00", "2017-04-01 16:00"])

      Timecop.freeze(Time.zone.parse("2017-03-15 16:00")) do

        with_current_site(site) do
          visit gobierto_people_events_path

          within ".calendar-component" do
            visible_month_events.each do |event|
              assert has_link?(event.starts_at.day)
            end
          end

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
