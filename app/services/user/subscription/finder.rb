# frozen_string_literal: true

class User::Subscription::Finder
  def self.user_subscribed_to?(user, subscribable_type, subscribable_id, site_id)
    find_user_subscriptions_for(subscribable_type, subscribable_id, site_id).include?(user.id)
  end

  def self.user_subscribed_by_broader_subscription_to?(user, subscribable_type, subscribable_id, site_id)
    find_broader_user_subscriptions_for(subscribable_type, subscribable_id, site_id).include?(user.id)
  end

  def self.subscriptions_for(subscribable_type, subscribable_id, site_id)
    find_user_subscriptions_for(subscribable_type, subscribable_id, site_id)
  end

  private

  def self.subscriptions_scope_for(subject_type, subject_id, site_id, exclude_specific_subscription: false)
    conditions = exclude_specific_subscription ? [] : [{ subscribable_type: subject_type, subscribable_id: subject_id, site_id: site_id }]

    if subject_id.present?
      conditions.push({ subscribable_type: subject_type, subscribable_id: nil, site_id: site_id })
    end

    if subject_type.include?("::")
      module_name = subject_type.split("::").first
      conditions.push({ subscribable_type: module_name, subscribable_id: nil, site_id: site_id })

      main_class = subject_type.split("::").last
      classes = main_class.underscore.split("_")
      if classes.length > 1
        conditions.push({ subscribable_type: "#{module_name}::#{classes.first.classify}", site_id: site_id })
      end
    end

    conditions.push({ subscribable_type: "Site", subscribable_id: site_id, site_id: site_id })

    scoped = User::Subscription.where(conditions.pop)
    while conditions.any?
      scoped = scoped.or(User::Subscription.where(conditions.pop))
    end
    scoped
  end
  private_class_method :subscriptions_scope_for

  def self.find_broader_user_subscriptions_for(subject_type, subject_id, site_id)
    subscriptions_scope_for(subject_type, subject_id, site_id, exclude_specific_subscription: true).pluck(:user_id).uniq
  end
  private_class_method :find_broader_user_subscriptions_for

  def self.find_user_subscriptions_for(subject_type, subject_id, site_id)
    subscriptions_scope_for(subject_type, subject_id, site_id).pluck(:user_id).uniq
  end
  private_class_method :find_user_subscriptions_for

end
