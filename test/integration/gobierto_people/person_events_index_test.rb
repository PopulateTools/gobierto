# frozen_string_literal: true

require "test_helper"
require "support/event_helpers"

module GobiertoPeople
  class PersonEventsIndexTest < ActionDispatch::IntegrationTest
    include ::EventHelpers

    attr_reader :reference_year

    def setup
      super
      @path = gobierto_people_events_path
      @path_for_json = gobierto_people_events_path(format: :json)
      @path_for_csv = gobierto_people_events_path(format: :csv)
      @reference_year = Date.today.year
    end

    def site
      @site ||= sites(:madrid)
    end

    def government_member
      government_members.first
    end

    def government_members
      @government_members ||= [
        gobierto_people_people(:richard),
        gobierto_people_people(:nelson)
      ]
    end

    def executive_member
      gobierto_people_people(:tamara)
    end

    def people
      @people ||= [government_member, executive_member]
    end

    def political_groups
      @political_groups ||= [
        gobierto_common_terms(:marvel_term),
        gobierto_common_terms(:dc_term)
      ]
    end

    def upcoming_events
      @upcoming_events ||= [
        gobierto_calendars_events(:nelson_tomorrow),
        gobierto_calendars_events(:richard_published),
        gobierto_calendars_events(:neil_published),
        gobierto_calendars_events(:richard_published_just_attending)
      ]
    end

    def past_events
      @past_events ||= [
        gobierto_calendars_events(:richard_published_past),
        gobierto_calendars_events(:nelson_yesterday),
        gobierto_calendars_events(:tamara_published_past)
      ]
    end

    def upcoming_event
      @upcoming_event ||= upcoming_events.first
    end

    def test_person_events_index
      with_current_site(site) do
        visit @path

        assert has_selector?("h2", text: "#{site.name}'s member agendas")
        assert has_no_link?("View more")
      end
    end

    def test_person_events_index_invalid_pagination
      with_current_site(site) do
        visit gobierto_people_events_path(page: 10)
        assert_equal 404, page.status_code
      end
    end

    def test_person_events_index_pagination
      skip "Disabled for performance reasons"
      government_member.events.destroy_all

      10.times do |i|
        create_event(person: government_member, starts_at: (Time.now.tomorrow + i.days).to_s, title: "Event #{i}")
      end

      with_current_site(site) do
        visit @path

        assert has_link?("View more")
        assert has_no_link?("Event 7")
        click_link "View more"

        assert has_link?("Event 7")
        assert has_no_link?("View more")
      end
    end

    def test_person_events_by_date
      government_member.events.destroy_all

      10.times do |i|
        create_event(person: government_member, starts_at: (Time.now.tomorrow - i.days).to_s, title: "Event #{i}")
      end
      ::GobiertoCalendars::Event.update_all(state: :pending)

      with_current_site(site) do
        visit gobierto_people_events_path(date: Date.yesterday.to_s)

        assert has_no_link?("Event 1")
        assert has_no_link?("Event 2")
        assert has_no_link?("Event 3")
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

    def test_person_events_filter_for_agenda_switcher
      with_current_site(site) do
        visit @path

        click_link "All"

        within ".agenda-switcher" do
          assert has_link? government_member.name
          assert has_link? executive_member.name
        end

        click_link "Government Team"

        within ".agenda-switcher" do
          assert has_link? government_member.name
          assert has_no_link? executive_member.name
        end

        click_link "Opposition"

        within ".agenda-switcher" do
          assert has_no_link? government_member.name
          assert has_no_link? executive_member.name
        end
      end
    end

    def test_person_events_filter_for_calendar_widget
      government_event = create_event(person: government_member, starts_at: "#{reference_year}-06-16")
      executive_event = create_event(person: executive_member, starts_at: "#{reference_year}-06-17")

      government_event_day = government_event.starts_at.day
      executive_event_day = executive_event.starts_at.day

      Timecop.freeze(Time.zone.parse("#{reference_year}-06-15")) do
        with_current_site(site) do
          visit @path

          click_link "All"

          within ".calendar-component" do
            assert has_link? government_event_day
            assert has_link? executive_event_day
          end

          click_link "Government Team"

          within ".calendar-component" do
            assert has_link? government_event_day
            assert has_no_link? executive_event_day
          end

          click_link "Opposition"

          within ".calendar-component" do
            assert has_no_link? government_event_day
            assert has_no_link? executive_event_day
          end
        end
      end
    end

    def test_person_events_filter_for_events_list
      government_event = create_event(person: government_member, title: "Government event", starts_at: "#{reference_year}-03-16")
      executive_event = create_event(person: executive_member, title: "Executive event", starts_at: "#{reference_year}-03-16")

      Timecop.freeze(Time.zone.parse("#{reference_year}-03-15")) do
        with_current_site(site) do
          visit @path

          click_link "All"

          within ".events-summary" do
            assert has_link?(government_event.title)
            assert has_link?(executive_event.title)
          end

          click_link "Government Team"

          within ".events-summary" do
            assert has_link?(government_event.title)
            assert has_no_link?(executive_event.title)
          end

          click_link "Opposition"

          within ".events-summary" do
            assert has_no_link?(government_event.title)
            assert has_no_link?(executive_event.title)
          end
        end
      end
    end

    def test_person_events_filter_for_groups_with_no_events
      with_current_site(site) do
        visit @path
        within '.filter_boxed' do
          assert has_link? 'Government Team'
          assert has_link? 'Opposition'
          assert has_link? 'Executive'
          assert has_link? 'All'
        end

        GobiertoCalendars::Event.person_events.destroy_all
        visit @path
        within '.filter_boxed' do
          assert has_no_link? 'Government Team'
          assert has_no_link? 'Opposition'
          assert has_no_link? 'Executive'
          assert has_link? 'All'
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
            next if event.collection.container.nil?

            assert has_selector?(".person_event-item", text: event.title)
            assert has_link?(event.title)
          end
        end
      end
    end

    def test_events_summary_with_no_upcoming_events
      past_event = gobierto_calendars_events(:richard_published_just_attending)

      Timecop.freeze(10.years.from_now) do
        with_current_site(site) do
          visit @path

          within '.events-summary' do
            assert_text('There are no future events. Take a look at past ones')
            assert has_link?(past_event.title)
          end
        end
      end
    end

    def test_events_summary_with_no_past_events
      freeze_date = 10.years.ago
      site.events.update_all(
        starts_at: freeze_date + 1.day,
        ends_at: freeze_date + 2.days
      )

      Timecop.freeze freeze_date do
        with_current_site(site) do
          visit @path

          click_link "Past events"

          assert_text("There are no past events.")
        end
      end
    end

    def test_events_summary_with_no_events
      ::GobiertoCalendars::Event.update_all(state: :pending)

      with_current_site(site) do
        visit @path

        assert_text("There are no future or past events.")
        within '.filter_boxed' do
          assert has_no_link? 'Government Team'
          assert has_no_link? 'Opposition'
          assert has_no_link? 'Executive'
          assert has_link? 'All'
        end
      end
    end

    def test_future_and_past_events_filter
      past_event = create_event(title: "Past event title", starts_at: "#{reference_year}-02-15")
      future_event = create_event(title: "Future event title", starts_at: "#{reference_year}-04-15")

      Timecop.freeze(Time.zone.parse("#{reference_year}-03-15")) do
        with_current_site(site) do
          visit @path

          within ".events-summary" do
            assert has_no_content?(past_event.title)
            assert has_content?(future_event.title)
          end

          click_link "Past events"

          within ".events-summary" do
            assert has_content?(past_event.title)
            assert has_no_content?(future_event.title)
          end
        end
      end
    end

    def test_future_and_past_events_filter_is_kept_when_changing_political_group
      with_current_site(site) do
        visit @path

        within ".events-summary .events-filter" do
          assert has_link? "Past events"
          assert has_no_link? "Agenda"
        end

        click_link "Past events"
        click_link "Government Team"

        within ".events-summary .events-filter" do
          assert has_no_link? "Past events"
          assert has_link? "Agenda"
        end

        click_link "Agenda"
        click_link "Executive"

        within ".events-summary .events-filter" do
          assert has_link? "Past events"
          assert has_no_link? "Agenda"
        end
      end
    end

    def test_calendar_component
      future_event = create_event(starts_at: "#{reference_year}-03-16")

      Timecop.freeze(Time.zone.parse("#{reference_year}-03-15")) do
        with_current_site(site) do
          visit gobierto_people_events_path(start_date: future_event.starts_at)

          within ".calendar-component" do
            assert has_link?(future_event.starts_at.day)
          end
        end
      end
    end

    def test_calendar_navigation_arrows
      past_event = create_event(starts_at: "#{reference_year}-02-15")
      future_event = create_event(starts_at: "#{reference_year}-04-15")

      Timecop.freeze(Time.zone.parse("#{reference_year}-03-15")) do
        with_current_site(site) do
          visit gobierto_people_events_path

          click_link "next-month-link"

          within ".calendar-component" do
            assert has_link?(future_event.starts_at.day)
          end

          visit gobierto_people_events_path

          click_link "previous-month-link"

          within ".calendar-component" do
            assert has_link?(past_event.starts_at.day)
          end
        end
      end
    end

    def test_calendar_event_links
      visible_month_events = ["#{reference_year}-02-28", "#{reference_year}-03-14", "#{reference_year}-03-16", "#{reference_year}-04-01"].map do |date|
        create_event(starts_at: date)
      end

      Timecop.freeze(Time.zone.parse("#{reference_year}-03-15")) do
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

    def test_filter_events_by_calendar_date_link
      past_event = create_event(title: "Past event title", starts_at: "#{reference_year}-03-10 11:00")
      future_event = create_event(title: "Future event title", starts_at: "#{reference_year}-03-20 11:00")

      Timecop.freeze(Time.zone.parse("#{reference_year}-03-15")) do
        with_current_site(site) do
          visit @path

          within ".events-summary" do
            assert has_no_content?(past_event.title)
            assert has_content?(future_event.title)
          end

          within ".calendar-component" do
            click_link past_event.starts_at.day
          end

          assert has_content? "Displaying events of #{past_event.starts_at.strftime("%b %d %Y")}"

          within ".events-summary" do
            assert has_content?(past_event.title)
            assert has_no_content?(future_event.title)
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
      skip "Subscription boxes are disabled"

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
        assert_equal upcoming_events.first.collection.container.name, json_response.first["creator_name"]
        assert_equal upcoming_events.first.collection.container.id, json_response.first["creator_id"]
        assert_equal upcoming_events.first.title, json_response.first["title"]
        assert_equal upcoming_events.first.description, json_response.first["description"]
      end
    end

    def test_person_events_index_csv
      with_current_site(site) do
        get @path_for_csv

        csv_response = CSV.parse(response.body, headers: true)
        assert_equal csv_response.by_row[0]["creator_name"], upcoming_events.first.collection.container.name
        assert_equal csv_response.by_row[0]["title"], upcoming_events.first.title
        assert_equal csv_response.by_row[0]["description"], upcoming_events.first.description
      end
    end
  end
end
