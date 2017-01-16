class User::SubscriptionsController < User::BaseController
  before_action :authenticate_user!, only: [:index, :destroy]

  def index
    @user_subscriptions = find_user_subscriptions.sorted
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

    if subscription_result
      flash[:notice] = t(".#{subscription_operation}_success")
    else
      flash[:alert] = t(
        ".error",
        details: @user_subscription_form.errors.full_messages.to_sentence,
        sign_in_path: new_user_sessions_path(domain: current_site.domain)
      )
    end

    redirect_to request.referrer
  end

  def destroy
    @user_subscription = find_user_subscription

    @user_subscription.destroy

    redirect_to user_subscriptions_path, notice: t(".success")
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
end
