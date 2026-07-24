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

      people_table = GobiertoPeople::Person.table_name
      categories_and_parties_with_activities = GobiertoCalendars::Event
        .published
        .by_site(current_site)
        .person_events
        .joins("INNER JOIN #{people_table} ON collection_items.container_id = #{people_table}.id")
        .distinct
        .pluck("#{people_table}.category", "#{people_table}.party")

      categories_with_activities = categories_and_parties_with_activities.map(&:first).compact.uniq
      parties_with_activities = categories_and_parties_with_activities.map(&:last).compact.uniq

      GobiertoPeople::Person.categories.each do |type, value|
        @present_groups[type] = categories_with_activities.include?(value) if @present_groups[type]
      end

      GobiertoPeople::Person.parties.each do |type, value|
        @present_groups[type] = parties_with_activities.include?(value) if @present_groups[type]
      end
    end
  end
end
