# frozen_string_literal: true

module GobiertoPeople
  module Api
    module V1
      class PeopleController < Api::V1::BaseController

        def index
          query = PeopleQuery.new(
            relation: current_site.people,
            conditions: permitted_conditions,
            limit: params[:limit]
          )

          render json: query.results, each_serializer: RowchartItemSerializer
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
            :from_date,
            :to_date
          ).to_h
        end

      end
    end
  end
end
