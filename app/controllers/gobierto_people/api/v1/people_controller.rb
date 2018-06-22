# frozen_string_literal: true

module GobiertoPeople
  module Api
    module V1
      class PeopleController < Api::V1::BaseController

        before_action :check_active_submodules

        def index
          top_people = PeopleQuery.new(
            relation: current_site.people,
            conditions: permitted_conditions,
            limit: params[:limit]
          ).results

          if params[:include_history] == "true"
            records = PeopleEventsHistoryQuery.new(
              relation: current_site.people.where(id: top_people.map(&:id)),
              conditions: permitted_conditions
            ).results

            result = []
            result_indexes = {}

            records.each do |record|
              if (index = result_indexes[record.name])
                result[index][:value] << { key: Time.zone.parse(record.year_month), value: record.custom_events_count }
              else
                result_indexes[record.name] = result.size
                result << {
                  key: record.name,
                  value: [
                    { key: Time.zone.parse(record.year_month), value: record.custom_events_count }
                  ]
                }
              end
            end

            render json: result
          else
            render json: top_people, each_serializer: RowchartItemSerializer
          end
        end

        private

        def parsed_parameters
          params[:from_date] = Time.zone.parse(params[:from_date]) if params[:from_date].is_a?(String)
          params[:to_date] = Time.zone.parse(params[:to_date]) if params[:to_date].is_a?(String)
          params
        end

        def permitted_conditions
          parsed_parameters.permit(
            :interest_group_id,
            :department_id,
            :from_date,
            :to_date
          ).to_h
        end

        def check_active_submodules
          head :forbidden unless agendas_submodule_active?
        end

      end
    end
  end
end
