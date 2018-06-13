# frozen_string_literal: true

module GobiertoPeople
  class RowchartItemsQuery

    class NotImplementedError < StandardError; end

    attr_reader :limit, :relation

    DEFAULT_LIMIT = 10

    def initialize(params = {})
      @relation = (params[:relation] || model.all).joins(events_association)
      append_query_conditions(params[:conditions]) if params[:conditions]
      @limit = params[:limit] || DEFAULT_LIMIT
    end

    def results
      relation.select("#{model.table_name}.*, COUNT(*) AS custom_events_count")
              .group(:id)
              .order("custom_events_count DESC")
              .limit(limit)
    end

    private

    def append_query_conditions(_conditions)
      raise NotImplementedError, "Must override this method"
    end

    def model
      raise NotImplementedError, "Must override this method"
    end

    def events_association
      :events
    end

    def events_table
      ::GobiertoCalendars::Event.table_name
    end

    def append_condition(attribute_name, attribute_value, operator = "=")
      @relation = relation.where("#{events_table}.#{attribute_name} #{operator} ?", attribute_value)
    end

  end
end
