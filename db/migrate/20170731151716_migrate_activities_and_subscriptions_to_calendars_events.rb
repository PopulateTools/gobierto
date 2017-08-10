class MigrateActivitiesAndSubscriptionsToCalendarsEvents < ActiveRecord::Migration[5.1]
  def change
    Activity.where(subject_type: "GobiertoPeople::PersonEvent").update_all(subject_type: "GobiertoCalendars::Event")
    Activity.where(action: "gobierto_people.person_event.published").update_all(action: "gobierto_calendars.event.published")
    Activity.where(action: "gobierto_people.person_event.updated").update_all(action: "gobierto_calendars.event.updated")
    User::Subscription.where(subscribable_type: "GobiertoPeople::PersonEvent").update_all(subscribable_type: "GobiertoCalendars::Event")
  end
end
