class User::SubscriptionPreferencesForm
  include ActiveModel::Model

  attr_accessor(
    :user,
    :site,
    :notification_frequency,
    :modules,
    :gobierto_people_people,
    :site_to_subscribe
  )

  validates :user, :site, :notification_frequency, presence: true

  def save
    save_subscriptions if valid?
  end

  private

  def save_subscriptions
    @user = user.tap do |user_attributes|
      user_attributes.notification_frequency = notification_frequency
    end

    if @user.valid?
      @user.save

      update_subscriptions_to_modules(modules)
      update_subscriptions_to_people(gobierto_people_people)
      update_subscription_to_site(site_to_subscribe)

     @user
    else
      promote_errors(@user.errors)

      false
    end
  end

  def promote_errors(errors_hash)
    errors_hash.each do |attribute, message|
      errors.add(attribute, message)
    end
  end

  def update_subscriptions_to_modules(modules)
    modules.each do |module_name|
      next if module_name.blank?

      gobierto_module = module_name.classify.pluralize.constantize
      @user.subscribe_to!(gobierto_module, site)
    end

    (site.configuration.modules.map(&:underscore) - modules).each do |module_name|
      next if module_name.blank?

      gobierto_module = module_name.classify.pluralize.constantize
      @user.unsubscribe_from!(gobierto_module, site)
    end
  end

  def update_subscriptions_to_people(people)
    people.each do |person_id|
      next if person_id.blank?

      person = GobiertoPeople::Person.find(person_id)
      @user.subscribe_to!(person, site)
    end

    (site.people.active.pluck(:id).map(&:to_s) - people).each do |person_id|
      next if person_id.blank?

      person = GobiertoPeople::Person.find(person_id)
      @user.unsubscribe_from!(person, site)
    end
  end

  def update_subscription_to_site(site_to_subscribe_id)
    if site_to_subscribe_id != "0"
      @user.subscribe_to!(site, site)
    else
      @user.unsubscribe_from!(site, site)
    end
  end
end
