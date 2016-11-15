class Admin::ActivitiesController < Admin::BaseController
  def index
    @activities = ActivityCollectionDecorator.new(Activity.global_admin_activities)
  end
end
