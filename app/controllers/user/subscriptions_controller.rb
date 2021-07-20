# frozen_string_literal: true

class User::SubscriptionsController < User::BaseController

  before_action :authenticate_user!, only: [:index, :destroy]

  invisible_captcha(
    only: [:create],
    honeypot: :ic_email,
    scope: :user_subscription
  )

  def index
    @user_notification_frequencies = get_user_notification_frequencies
    @user_notification_modules = get_user_notification_modules
    @user_notification_gobierto_people_people = get_user_notification_gobierto_people_people
    @user_notification_gobierto_participation_processes = get_user_notification_gobierto_participation_processes
    @user_subscription_preferences_form = User::SubscriptionPreferencesForm.new(
      user: current_user,
      site: current_site,
      notification_frequency: current_user.notification_frequency,
      site_to_subscribe: get_current_user_subsciption_to_site,
      modules: get_current_user_subscribed_modules,
      gobierto_people_people: get_current_user_subscribed_gobierto_people_people,
      gobierto_participation_processes: get_current_user_subscribed_gobierto_participation_processes
    )
  end

  def create
    @user_subscription_form = User::SubscriptionForm.new(
      user_subscription_params.merge(
        user: current_user,
        site: current_site,
        creation_ip: remote_ip
      )
    )

    subscription_operation, subscription_result = @user_subscription_form.save

    respond_to do |format|
      format.html do
        if subscription_result
          flash[:notice] = t(".#{subscription_operation}_success")
        else
          flash[:alert] = t(
            ".error",
            details: @user_subscription_form.errors.full_messages.to_sentence,
            sign_in_path: new_user_sessions_path(host: current_site.domain)
          )
        end
        redirect_back(fallback_location: root_path)
      end
      format.js
    end
  end

  def destroy
    @user_subscription = find_user_subscription
    @subscribable = @user_subscription.subscribable
    @user_subscription.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = t(".success")
      end
      format.js
    end
  end

  private

  def find_user_subscription
    find_user_subscriptions.find(params[:id])
  end

  def find_user_subscriptions
    User::Subscription.where(
      user: current_user,
      site: current_site
    )
  end

  def user_subscription_params
    params.require(:user_subscription).permit(
      :subscribable_type,
      :subscribable_id,
      :user_email
    )
  end

  def get_user_notification_frequencies
    User.notification_frequencies
  end

  def get_user_notification_modules
    current_site.configuration.modules_with_notifications.map{ |m| [m.underscore, m.underscore] }
  end

  def get_user_notification_gobierto_people_people
    current_site.people.active.sorted
  end

  def get_current_user_subscribed_modules
    current_site.configuration.modules.select do |module_name|
      current_user.subscribed_to?(module_name.constantize, current_site)
    end.map(&:underscore)
  end

  def get_current_user_subscribed_gobierto_people_people
    get_user_notification_gobierto_people_people.select do |person|
      current_user.subscribed_to?(person, current_site)
    end.map(&:id)
  end

  def get_current_user_subsciption_to_site
    if current_user.subscribed_to?(current_site, current_site)
      current_site.id
    end
  end

  def get_user_notification_gobierto_participation_processes
    current_site.processes.active
  end

  def get_current_user_subscribed_gobierto_participation_processes
    if current_user.subscribed_to?(GobiertoParticipation::Process.new, current_site, :user_subscribed_by_broader_subscription_to?)
      get_user_notification_gobierto_participation_processes.map(&:id)
    else
      current_user.subscriptions.specific.where(subscribable_type: "GobiertoParticipation::Process", site: current_site).pluck(:subscribable_id)
    end
  end
end
