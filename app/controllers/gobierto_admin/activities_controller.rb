module GobiertoAdmin
  class ActivitiesController < BaseController
    def index
      raise_action_not_allowed unless current_admin.managing_user?

      @activities = ActivityCollectionDecorator.new(Activity.global_admin_activities.page(params[:page]))
    end
  end
end
