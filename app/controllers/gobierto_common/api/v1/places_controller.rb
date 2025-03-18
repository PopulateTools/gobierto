# frozen_string_literal: true

module GobiertoCommon
  module Api
    module V1
      class PlacesController < ApiBaseController
        # GET /api/v1/places.json
        def index
          places = JSON.parse(File.read(Rails.root.join("db/data/places.json")))
          if params[:query].present?
            places = places.select { |place| place["name"].downcase.include?(params[:query].downcase) }
          end

          render json: { suggestions: places }
        end
      end
    end
  end
end
