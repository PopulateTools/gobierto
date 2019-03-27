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
                result[index][:value] << record_value_item(record)
              else
                result_indexes[record.name] = result.size
                result << {
                  key: record.name,
                  value: [record_value_item(record)],
                  properties: {
                    url: gobierto_people_person_past_events_url(record.slug, date_range_params.merge(page: false))
                  }
                }
              end
            end

            # sort result according to person events count
            people_order = Hash[
              *top_people.pluck(:name).each_with_index.collect do |person_name, index|
                [person_name, index]
              end.flatten
            ]
            result.sort! { |x, y| people_order[x[:key]] <=> people_order[y[:key]] }

            render json: result
          else
            render json: top_people, each_serializer: RowchartItemSerializer, date_range_query: date_range_params.to_query
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

        def date_range_params
          parsed_parameters.slice(:from_date, :to_date).permit!.transform_keys { |k| { "from_date" => "start_date", "to_date" => "end_date" }[k] }.transform_values { |v| v&.strftime("%Y-%m-%d") }
        end

        def check_active_submodules
          head :forbidden unless agendas_submodule_active?
        end

        def record_value_item(record)
          year_month = Time.zone.parse(record.year_month)
          {
            key: year_month,
            value: record.custom_events_count,
            properties: {
              url: gobierto_people_person_past_events_url(
                record.slug,
                page: false,
                start_date: year_month.to_date.to_s(:db),
                end_date: (year_month.to_date + 1.month).to_s(:db)
              )
            }
          }
        end

      end
    end
  end
end
