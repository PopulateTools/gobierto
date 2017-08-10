class MigrateActivitiesAndSubscriptionsToIssues < ActiveRecord::Migration[5.1]
  def change
    Activity.where(subject_type: 'GobiertoParticipation::Issue').update_all(subject_type: 'Issue')
    Activity.where(action: 'gobierto_participation.issue_created').update_all(action: 'issues.issue_created')
    Activity.where(action: 'gobierto_participation.issue_updated').update_all(action: 'issues.issue_updated')
    User::Subscription.where(subscribable_type: 'GobiertoParticipation::Issue').update_all(subscribable_type: 'Issue')
  end
end
