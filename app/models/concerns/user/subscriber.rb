module User::Subscriber
  extend ActiveSupport::Concern

  def subscribed_to?(subscribable, site)
    if subscribable.is_a?(Class)
      User::Subscription.exists?(
        user: self,
        site: site,
        subscribable_type: subscribable.name,
        subscribable_id: nil
      )
    else
      User::Subscription.exists?(
        user: self,
        site: site,
        subscribable: subscribable
      )
    end
  end

  def subscribe_to!(subscribable, site)
    return true if subscribed_to?(subscribable, site)

    if subscribable.is_a?(Class)
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
    return true unless subscribed_to?(subscribable, site)

    if subscribable.is_a?(Class)
      User::Subscription.find_by(
        user: self,
        site: site,
        subscribable_type: subscribable.name,
        subscribable_id: nil
      ).delete
    else
      User::Subscription.find_by(
        user: self,
        site: site,
        subscribable: subscribable
      ).delete
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
