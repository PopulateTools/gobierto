class User::SubscriptionPreferencesForm
  include ActiveModel::Model

  attr_accessor(
    :user,
    :site,
    :notification_frequency,
    :modules,
    :gobierto_people_people,
    :gobierto_budget_consultations_consultations,
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
      update_subscriptions_to_consultations(gobierto_budget_consultations_consultations)

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
    modules = Array(modules)
    modules.each do |module_name|
      next if module_name.blank?

      gobierto_module = module_name.camelize.constantize
      @user.subscribe_to!(gobierto_module, site)
    end

    (site.configuration.modules.map(&:underscore) - modules).each do |module_name|
      next if module_name.blank?

      gobierto_module = module_name.camelize.constantize
      @user.unsubscribe_from!(gobierto_module, site)
    end
  end

  def update_subscriptions_to_people(people)
    people = Array(people)

    people.each do |person_id|
      next if person_id.blank?

      person = GobiertoPeople::Person.find(person_id)
      @user.subscribe_to!(person, site)
    end

    (site.people.active.pluck(:id).map(&:to_s) - people).each do |person_id|
      next if person_id.blank?

      person = site.people.find(person_id)
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

  def update_subscriptions_to_consultations(budget_consultations)
    budget_consultations = Array(budget_consultations)

    budget_consultations.each do |consultation_id|
      next if consultation_id.blank?

      consultation = GobiertoBudgetConsultations::Consultation.find(consultation_id)
      @user.subscribe_to!(consultation, site)
    end

    (site.budget_consultations.active.pluck(:id).map(&:to_s) - budget_consultations).each do |consultation_id|
      next if consultation_id.blank?

      consultation = site.budget_consultations.find(consultation_id)
      @user.unsubscribe_from!(consultation, site)
    end
  end
end
