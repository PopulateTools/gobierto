# frozen_string_literal: true

module GobiertoPeople
  class QueryWithEvents

    class NotImplementedError < StandardError; end
    class AssociationNotFound < StandardError; end

    attr_reader :relation

    def method_missing(*args, &block)
      relation.send(*args, &block)
    end

    def initialize(params = {})
      @source = (params[:source] || model)
      add_events_relation
      append_condition(:starts_at, params[:start_date], ">=") if params[:start_date]
      append_condition(:ends_at, params[:end_date], "<=") if params[:end_date]
      params[:not_null].each do |attr|
        append_not_null_condition(attr)
      end if params[:not_null]
    end

    def update_relation
      @relation = yield(@relation)
    end

    def self.filter_people(params = {})
      params[:people_relation].left_outer_joins(attending_person_events: :event)
                              .where(%{
        #{people_linked_throught_events_sql(params)}
        gp_people.id IN (#{people_linked_through_trips_sql(params)}) OR
        gp_people.id IN (#{people_linked_through_invitations_sql(params)}) OR
        gp_people.id IN (#{people_linked_through_gifts_sql(params)})
      })
    end

    def self.sanitize_sql(sql_array)
      ActiveRecord::Base.send(:sanitize_sql, sql_array)
    end

    ## private

    def self.people_linked_throught_events_sql(params = {})
      sql = ""

      sql += sanitize_sql([" gc_events.department_id = ?", params[:department_id]]) if params[:department_id]

      if params[:from_date] && sql.blank?
        sql += sanitize_sql([" gc_events.starts_at >= ?", params[:from_date]])
      elsif params[:from_date]
        sql += sanitize_sql([" AND gc_events.starts_at >= ?", params[:from_date]])
      end

      if params[:to_date] && sql.blank?
        sql += sanitize_sql([" gc_events.ends_at < ?", params[:to_date]])
      elsif params[:to_date]
        sql += sanitize_sql([" AND gc_events.ends_at < ?", params[:to_date]])
      end

      sql.present? ? "(#{sql}) OR " : nil
    end
    private_class_method :people_linked_throught_events_sql

    def self.people_linked_through_trips_sql(params = {})
      people = GobiertoPeople::Trip.select("DISTINCT(person_id)")
      people = people.where(department_id: params[:department_id]) if params[:department_id]
      people = people.reorder("")

      people = people.where("start_date >= ?", params[:from_date]) if params[:from_date]
      people = people.where("end_date < ?", params[:to_date]) if params[:to_date]
      people.to_sql
    end
    private_class_method :people_linked_through_trips_sql

    def self.people_linked_through_invitations_sql(params = {})
      people = GobiertoPeople::Invitation.select("DISTINCT(person_id)")
      people = people.where(department_id: params[:department_id]) if params[:department_id]
      people = people.reorder("")

      people = people.where("start_date >= ?", params[:from_date]) if params[:from_date]
      people = people.where("end_date < ?", params[:to_date]) if params[:to_date]
      people.to_sql
    end
    private_class_method :people_linked_through_invitations_sql

    def self.people_linked_through_gifts_sql(params = {})
      people = GobiertoPeople::Gift.select("DISTINCT(person_id)")
      people = people.where(department_id: params[:department_id]) if params[:department_id]
      people = people.reorder("")

      people = people.where("date >= ?", params[:from_date]) if params[:from_date]
      people = people.where("date < ?", params[:to_date]) if params[:to_date]
      people.to_sql
    end
    private_class_method :people_linked_through_gifts_sql

    private

    def model
      raise NotImplementedError, "Must override this method"
    end

    def add_events_relation
      @relation = if @source.klass == GobiertoCalendars::Event
                    @source
                  elsif @source.reflect_on_association(:event)
                    @source.joins(:event)
                  elsif @source.reflect_on_association(:events)
                    @source.joins(:events).distinct
                  elsif @source.reflect_on_association(:attending_events)
                    @source.joins(:attending_events).distinct
                  else
                    raise AssociationNotFound, "Association with events not found for source"
                  end
    end

    def events_table
      ::GobiertoCalendars::Event.table_name
    end

    def append_condition(attribute_name, attribute_value, operator = "=")
      @relation = relation.where("#{events_table}.#{attribute_name} #{operator} ?", attribute_value)
    end

    def append_not_null_condition(attribute_name)
      @relation = relation.where.not(events_table => { attribute_name => nil })
    end
  end
end
