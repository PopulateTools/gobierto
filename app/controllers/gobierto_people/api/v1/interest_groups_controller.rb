# frozen_string_literal: true

module GobiertoPeople
  module Api
    module V1
      class InterestGroupsController < Api::V1::BaseController

        def index
          query = InterestGroupsQuery.new(
            relation: current_site.interest_groups,
            conditions: permitted_conditions,
            limit: records_to_return
          )

          render(
            json: query.results,
            each_serializer: InterestGroupRowchartSerializer
          )
        end

        private

        def parsed_parameters
          params[:from_date] = Time.zone.parse(params[:from_date]) if params[:from_date]
          params[:to_date] = Time.zone.parse(params[:to_date]) if params[:to_date]
          params
        end

        def permitted_conditions
          parsed_parameters.permit(
            :department_id,
            :person_id,
            :from_date,
            :to_date,
            :limit
          ).to_h
        end

        def records_to_return
          params[:limit] || 10
        end

      end
    end
  end
end
