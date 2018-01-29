# frozen_string_literal: true

module GobiertoPlans
  class PlansController < GobiertoPlans::ApplicationController
    include User::SessionHelper

    def index
    end


    def show


      respond_to do |format|
        format.html
        format.json do
          render(
            json: { plan: @plan.to_json }
          )
        end
      end
    end
  end
end
