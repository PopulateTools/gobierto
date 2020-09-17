# frozen_string_literal: true

module GobiertoPeople
  module Api
    module V1
      class PeopleController < Api::V1::BaseController

        before_action :check_active_submodules

        def index
          department = current_site.departments.find_by(id: permitted_conditions[:department_id])
          charges = if params[:filter_positions] == "true"
                      current_site.historical_charges.with_department(department).between_dates(permitted_conditions).reverse_sorted.group_by(&:person_id)
                    else
                      current_site.historical_charges.where(person_id: top_people.map(&:id)).reverse_sorted.group_by(&:person_id)
                    end

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
            serializer = params[:serializer] == "rowchart" ? GobiertoPeople::RowchartItemSerializer : GobiertoPeople::PersonSerializer
            render(
              json: top_people,
              each_serializer: serializer,
              date_range_query: date_range_params.to_query,
              date_range_params: date_range_params.to_h,
              charges: charges,
              exclude_content_block_records: true
            )
          end
        end

        private

        def top_people
          @top_people ||= begin
                            query = PeopleWithActivitiesQuery.new(
                              site: current_site,
                              relation: current_site.people,
                              conditions: permitted_conditions,
                              limit: params[:limit]
                            )
                            if params[:include_all_activities]
                              GobiertoPeople::Person.where(id: query.people_with_activities)
                            else
                              query.results
                            end
                          end
        end

        def parsed_parameters
          params[:start_date] = Time.zone.parse(params[:start_date]) if params[:start_date].is_a?(String)
          params[:end_date] = Time.zone.parse(params[:end_date]) if params[:end_date].is_a?(String)
          params
        end

        def permitted_conditions
          parsed_parameters.permit(
            :interest_group_id,
            :department_id,
            :start_date,
            :end_date
          ).to_h
        end

        def date_range_params
          parsed_parameters.slice(:start_date, :end_date).permit!.transform_values { |v| v&.strftime("%Y-%m-%d") }
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
