# frozen_string_literal: true

module GobiertoAdmin
  class ActivitiesController < BaseController
    def index
      @activities = ActivityCollectionDecorator.new(Activity.global_admin_activities.page(params[:page]))
    end
  end
end
