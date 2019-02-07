# frozen_string_literal: true

module GobiertoPeople
  class QueryWithActivities
    attr_reader :relation

    def method_missing(*args, &block)
      relation.send(*args, &block)
    end

    def initialize(params = {})
      @relation = params[:source]
      @joins = params[:include_joins] || {}
      @joins.each do |_, join_name|
        add_join(join_name)
      end
      add_interval_conditions(params[:start_date], params[:end_date])
      params[:not_null]&.each do |association, attributes|
        append_not_null_conditions(association, attributes)
      end
    end

    def update_relation
      @relation = yield(@relation)
    end

    private

    ASSOCIATIONS = {
      events: { model: ::GobiertoCalendars::Event, start_attribute: "starts_at", end_attribute: "ends_at" },
      invitations: { model: ::GobiertoPeople::Invitation, start_attribute: "start_date", end_attribute: "end_date" },
      trips: { model: ::GobiertoPeople::Trip, start_attribute: "start_date", end_attribute: "end_date" },
      gifts: { model: ::GobiertoPeople::Gift, start_attribute: "date", end_attribute: "date" }
    }.freeze

    def add_join(association)
      @relation = relation.left_outer_joins(association).distinct if relation.reflect_on_association(association)
    end

    def add_interval_conditions(start_date, end_date)
      return if start_date.blank? && end_date.blank?

      @relation = relation.where(interval_conditions(start_date, end_date), start: start_date, end: end_date)
    end

    def append_not_null_conditions(association, attributes)
      table_name = ASSOCIATIONS[association][:model].table_name
      attributes.each do |attribute_name|
        @relation = relation.where.not(table_name => { attribute_name => nil })
      end
    end

    def condition_components_for_attribute(attribute, operator = nil)
      operator ||= attribute == :start ? ">=" : "<="

      @joins.inject({}) do |result, (association, _)|
        table_name = ASSOCIATIONS[association][:model].table_name
        table_attribute = ASSOCIATIONS[association][:"#{attribute}_attribute"]

        result.update(association => "#{table_name}.#{table_attribute} #{operator} :#{attribute}")
      end
    end

    def interval_conditions(start_date, end_date)
      start_conditions = start_date.present? ? condition_components_for_attribute(:start) : {}
      end_conditions = end_date.present? ? condition_components_for_attribute(:end) : {}
      start_conditions.merge(end_conditions) do |_, start_condition, end_condition|
        [start_condition, end_condition].compact.join(" and ")
      end.values.join(" or ")
    end

    def append_condition(attribute_name, attribute_value, operator = "=")
      @relation = relation.where("#{events_table}.#{attribute_name} #{operator} ?", attribute_value)
    end
  end
end
