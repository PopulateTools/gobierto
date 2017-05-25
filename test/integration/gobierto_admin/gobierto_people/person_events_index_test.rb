# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  module GobiertoPeople
    class PersonEventsIndexTest < ActionDispatch::IntegrationTest
      def setup
        super
        @person_events_path = admin_people_person_events_path(person)
        @person_pending_events_path = admin_people_person_pending_events_path(person)
        @person_published_events_path = admin_people_person_published_events_path(person)
        @person_past_events_path = admin_people_person_past_events_path(person)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_person_events_index
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @person_events_path

            within 'table.person-events-list tbody' do
              assert has_selector?('tr', count: person.events.count)

              person.events.each do |event|
                assert has_selector?("tr#person-event-item-#{event.id}")
              end
            end
          end
        end
      end

      def test_person_pending_events_index
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @person_pending_events_path

            within 'table.person-events-list tbody' do
              assert has_selector?('tr', count: person.events.pending.count)

              person.events.pending.each do |event|
                assert has_selector?("tr#person-event-item-#{event.id}")
              end
            end
          end
        end
      end

      def test_person_published_events_index
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @person_published_events_path

            within 'table.person-events-list tbody' do
              assert has_selector?('tr', count: person.events.published.count)

              person.events.published.each do |event|
                assert has_selector?("tr#person-event-item-#{event.id}")

                within "tr#person-event-item-#{event.id}" do
                  if event.published?
                    assert has_content?('Published')
                  else
                    assert has_content?('Draft')
                  end
                  assert has_link?('View event')
                end
              end
            end
          end
        end
      end

      def test_person_past_events_index
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @person_past_events_path

            within 'table.person-events-list tbody' do
              assert has_selector?('tr', count: person.events.past.count)

              person.events.past.each do |event|
                assert has_selector?("tr#person-event-item-#{event.id}")
              end
            end
          end
        end
      end

      def test_person_event_filtering
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @person_events_path

            within '.sub_filter ul', match: :first do
              assert has_selector?(
                '.all-events-filter',
                text: "All (#{person.events.count})"
              )

              assert has_selector?(
                '.pending-events-filter',
                text: "Moderation pending (#{person.events.pending.count})"
              )

              assert has_selector?(
                '.published-events-filter',
                text: "Published events (#{person.events.published.count})"
              )

              assert has_selector?(
                '.past-events-filter',
                text: "Past events (#{person.events.past.count})"
              )
            end
          end
        end
      end
    end
  end
end
