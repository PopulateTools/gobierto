# frozen_string_literal: true

module GobiertoPeople
  class QueryWithEvents

    class NotImplementedError < StandardError; end

    attr_reader :relation

    def initialize(params = {})
      @relation = (params[:relation] || model.all)
      @relation = relation.joins(events_association)
      append_condition(:starts_at, params[:start_date], ">=") if params[:start_date]
      append_condition(:ends_at, params[:end_date], "<=") if params[:end_date]
      params[:not_null].each do |attr|
        append_not_null_condition(attr)
      end if params[:not_null]
    end

    def update_relation
      @relation = yield(@relation)
    end

    private

    def model
      raise NotImplementedError, "Must override this method"
    end

    def events_association
      @events_association ||= [:event, :events].find { |assoc| relation.reflect_on_association(assoc) }
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
