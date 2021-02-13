# frozen_string_literal: true

module GobiertoPeople
  module Api
    module V1
      class InterestGroupsController < Api::V1::BaseController

        before_action :check_active_submodules

        def index
          query = InterestGroupsQuery.new(
            relation: current_site.interest_groups,
            conditions: permitted_conditions,
            limit: params[:limit]
          )

          render(
            json: query.results,
            each_serializer: RowchartItemSerializer,
            date_range_query: date_range_params.to_query
          )
        end

        private

        def parsed_parameters
          @parsed_parameters ||= begin
                                   params[:start_date] = Time.zone.parse(params[:start_date]) if params[:start_date]
                                   params[:end_date] = Time.zone.parse(params[:end_date]) if params[:end_date]
                                   params
                                 end
        end

        def permitted_conditions
          parsed_parameters.permit(
            :department_id,
            :person_id,
            :start_date,
            :end_date
          ).to_h
        end

        def date_range_params
          parsed_parameters.slice(:start_date, :end_date).permit!.transform_values { |v| v&.strftime("%Y-%m-%d") }
        end

        def check_active_submodules
          head :forbidden unless interest_groups_submodule_active?
        end

      end
    end
  end
end
