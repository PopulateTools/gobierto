module GobiertoAdmin
  class ActivitiesController < BaseController
    def index
      @activities = ActivityCollectionDecorator.new(Activity.global_admin_activities)
    end
  end
end
