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

        def permitted_conditions
          params.permit(
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
