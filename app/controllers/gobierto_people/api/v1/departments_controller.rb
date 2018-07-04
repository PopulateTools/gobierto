# frozen_string_literal: true

module GobiertoPeople
  module Api
    module V1
      class DepartmentsController < Api::V1::BaseController

        before_action :check_active_submodules

        def index
          top_departments = DepartmentsQuery.new(
            relation: Department.where(site: current_site),
            conditions: permitted_conditions,
            limit: params[:limit]
          ).results

          if params[:include_history] == "true"
            records = DepartmentsQuery.new(
              relation: Department.where(id: top_departments.map(&:id)),
              conditions: permitted_conditions
            ).results_with_history

            result = []
            result_indexes = {}

            records.each do |record|
              if (index = result_indexes[record.short_name])
                result[index][:value] << record_value_item(record)
              else
                result_indexes[record.short_name] = result.size
                result << {
                  key: record.short_name,
                  value: [record_value_item(record)],
                  properties: {
                    url: gobierto_people_department_path(record.slug, date_range_params.merge(page: false))
                  }
                }
              end
            end

            # sort result according to department events count
            departments_order = Hash[
              *top_departments.map(&:short_name).each_with_index.collect do |department_name, index|
                [department_name, index]
              end.flatten
            ]
            result.sort! { |x, y| departments_order[x[:key]] <=> departments_order[y[:key]] }

            render json: result
          else
            render json: top_departments, each_serializer: DepartmentRowchartSerializer, date_range_query: date_range_params.to_query
          end
        end

        private

        def parsed_parameters
          @parsed_parameters ||= begin
                                   params[:from_date] = Time.zone.parse(params[:from_date]) if params[:from_date]
                                   params[:to_date] = Time.zone.parse(params[:to_date]) if params[:to_date]
                                   params
                                 end
        end

        def permitted_conditions
          parsed_parameters.permit(
            :interest_group_id,
            :person_id,
            :from_date,
            :to_date
          ).to_h
        end

        def date_range_params
          parsed_parameters.slice(:from_date, :to_date).permit!.transform_keys{ |k| {"from_date" => "start_date", "to_date" => "end_date"}[k] }.transform_values{ |v| v&.strftime("%Y-%m-%d") }
        end

        def check_active_submodules
          head :forbidden unless departments_submodule_active?
        end

        def record_value_item(record)
          year_month = Time.zone.parse(record.year_month)
          {
            key: year_month,
            value: record.custom_events_count,
            properties: {
              url: gobierto_people_department_path(
                record.slug,
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
