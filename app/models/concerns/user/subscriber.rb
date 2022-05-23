module User::Subscriber
  extend ActiveSupport::Concern

  def subscribed_to?(subscribable, site, finder_method = :user_subscribed_to?)
    # Disable any new subscriptions from being created
    return true

    if subscribable.is_a?(Class) || subscribable.is_a?(Module)
      User::Subscription::Finder.send(finder_method, self, subscribable.name, nil, site.id)
    else
      User::Subscription::Finder.send(finder_method, self, subscribable.class.name, subscribable.id, site.id)
    end
  end

  def subscribe_to!(subscribable, site)
    return true if subscribed_to?(subscribable, site)

    if subscribable.is_a?(Class) || subscribable.is_a?(Module)
      User::Subscription.create!(
        user: self,
        site: site,
        subscribable_type: subscribable.name,
        subscribable_id: nil
      )
    else
      User::Subscription.create!(
        user: self,
        site: site,
        subscribable: subscribable
      )
    end
  end

  def unsubscribe_from!(subscribable, site)
    if subscribable.is_a?(Class) || subscribable.is_a?(Module)
      User::Subscription.find_by(
        user: self,
        site: site,
        subscribable_type: subscribable.name,
        subscribable_id: nil
      ).try(:delete)
    else
      User::Subscription.find_by(
        user: self,
        site: site,
        subscribable: subscribable
      ).try(:delete)
    end
  end

  def toggle_subscription!(subscribable, site)
    if subscribed_to?(subscribable, site)
      [:delete, unsubscribe_from!(subscribable, site).present?]
    else
      [:create, subscribe_to!(subscribable, site).present?]
    end
  end
end
