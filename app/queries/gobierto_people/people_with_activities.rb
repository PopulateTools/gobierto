# frozen_string_literal: true

module GobiertoPeople
  class PeopleWithActivities
    attr_reader :relation

    def method_missing(*args, &block)
      relation.send(*args, &block)
    end

    def initialize(params = {})
      @relation = params[:people_scope]
      add_conditions(params[:start_date], params[:end_date])
    end

    private

    ASSOCIATIONS = {
      events: { model: ::GobiertoCalendars::Event, start_attribute: "starts_at", end_attribute: "ends_at", person_fk: "gc_event_attendees.person_id" },
      invitations: { model: ::GobiertoPeople::Invitation, start_attribute: "start_date", end_attribute: "end_date", person_fk: "person_id" },
      trips: { model: ::GobiertoPeople::Trip, start_attribute: "start_date", end_attribute: "end_date", person_fk: "person_id" },
      gifts: { model: ::GobiertoPeople::Gift, start_attribute: "date", end_attribute: "date", person_fk: "person_id" }
    }.freeze

    def add_conditions(start_date, end_date)
      conditions = []
      ASSOCIATIONS.each do |association_name, association_attrs|
        table_name = association_attrs[:model].table_name
        person_fk = association_attrs[:person_fk]
        time_conditions = []

        if start_date.present?
          time_conditions.push("#{table_name}.#{association_attrs[:start_attribute]} >= '#{start_date.to_s(:db)}'")
        end

        if end_date.present?
          time_conditions.push("#{table_name}.#{association_attrs[:end_attribute]} <= '#{end_date.to_s(:db)}'")
        end

        association = association_attrs[:model].where(person_fk => @relation.select("id"))
        if time_conditions.any?
          if association_name == :events
            association = association.joins(:attendees)
          end
          association = association.where(time_conditions.join(" AND ")).select(person_fk)
        end

        condition_query = "( #{@relation.table_name}.id IN (#{association.to_sql}))"

        conditions.push(condition_query)
      end

      @relation = relation.where(conditions.join(" OR "))
    end
  end
end
