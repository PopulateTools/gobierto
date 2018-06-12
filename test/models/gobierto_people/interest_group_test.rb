# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class InterestGroupTest < ActiveSupport::TestCase

    def google
      @google ||= gobierto_people_interest_groups(:google)
    end

    def accenture
      @accenture ||= gobierto_people_interest_groups(:accenture)
    end

    def pepsi
      @pepsi ||= gobierto_people_interest_groups(:pepsi)
    end

    def pepsi_events
      @pepsi_events ||= [
        gobierto_calendars_events(:tamara_justice_department_event_pepsi_old),
        gobierto_calendars_events(:tamara_justice_department_event_pepsi_very_old)
      ]
    end

    def test_status
      assert_equal "Inscribed", google.status
      assert_nil accenture.status
    end

    def test_registry
      assert_equal "Registry of Interest Groups of Madrid City Council", google.registry
      assert_nil accenture.registry
    end

    def test_events_count
      assert_equal pepsi_events.count, pepsi.events_count
    end

    def test_events_count_when_attribute_overriden_by_query
      group = InterestGroup.where(id: pepsi.id)
                           .select("id, name, 123 AS events_count")
                           .first

      assert_equal pepsi.name, group.name
      assert_equal 123, group.events_count
    end

  end
end
