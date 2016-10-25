module GobiertoBudgets
  module Api
    class PlacesController < ApplicationController
      def index
        @places = GobiertoBudgets::Place.search(params[:q])

        respond_to do |format|
          format.json do
            render json: @places.to_json
          end
        end
      end
    end
  end
end
