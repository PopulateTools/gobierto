module GobiertoPeople
  module PeopleClassificationHelper
    extend ActiveSupport::Concern

    private

    def set_present_groups(relation=nil)
      relation ||= current_site.people.active
      @present_groups = relation.presence_by_group_type
    end

    def set_present_groups_with_published_activities(relation=nil)
      set_present_groups(relation)
      events = GobiertoCalendars::Event.published.by_site(current_site).person_events

      GobiertoPeople::Person.categories.keys.each do |type|
        @present_groups[type] = events.by_person_category(type).any? if @present_groups[type]
      end

      GobiertoPeople::Person.parties.keys.each do |type|
        @present_groups[type] = events.by_person_party(type).any? if @present_groups[type]
      end
    end
  end
end
