class MigrateActivitiesAndSubscriptionsToCalendarsEvents < ActiveRecord::Migration[5.1]
  def change
    Activity.where(subject_type: "GobiertoPeople::PersonEvent").update_all(subject_type: "GobiertoCalendars::Event")
    User::Subscription.where(subscribable_type: "GobiertoPeople::PersonEvent").update_all(subscribable_type: "GobiertoCalendars::Event")
  end
end
