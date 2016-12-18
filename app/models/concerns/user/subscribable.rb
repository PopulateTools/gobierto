module User::Subscribable
  extend ActiveSupport::Concern

  included do
    def self.subscribable_label
      model_name.human
    end
  end

  def subscribed?(subscriber, site)
    User::Subscription.exists?(
      user: subscriber,
      site: site,
      subscribable: self
    )
  end

  def subscribe!(subscriber, site)
    return true if subscribed?(subscriber, site)

    User::Subscription.create!(
      user: subscriber,
      site: site,
      subscribable: self
    )
  end

  def unsubscribe!(subscriber, site)
    return true unless subscribed?(subscriber, site)

    User::Subscription.find_by(
      user: subscriber,
      site: site,
      subscribable: self
    ).delete
  end

  def subscribable_label
    try(:title) || try(:name)
  end
end
