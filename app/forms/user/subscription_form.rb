# frozen_string_literal: true

class User::SubscriptionForm < BaseForm

  attr_accessor(
    :user,
    :site,
    :subscribable,
    :subscribable_type,
    :subscribable_id,
    :user_email,
    :creation_ip
  )

  validates :user, :site, :subscribable, presence: true
  validates :user_email, format: { with: User::EMAIL_ADDRESS_REGEXP }, allow_nil: true

  def save
    toggle_user_subscription if valid?
  end

  def user
    @user ||= begin
      user_registration_form = User::RegistrationForm.new(
        email: user_email,
        site: site,
        creation_ip: creation_ip
      )

      user_registration_form.save
      promote_errors(user_registration_form.errors)
      user_registration_form.user
    end
  end

  def subscribable
    @subscribable ||= begin
      if @subscribable_id.present?
        subscribable_class.find_by(id: @subscribable_id)
      else
        subscribable_class
      end
    end
  end

  def subscribable_type
    @subscribable_type ||= if @subscribable.is_a?(Module)
                             @subscribable.to_s
                           else
                             @subscribable.try(:model_name)
                           end
  end

  def subscribable_id
    @subscribable_id ||= @subscribable.try(:id)
  end

  private

  def subscribable_class
    if subscribable_type.is_a?(String)
      subscribable_type.try(:constantize)
    else
      subscribable_type
    end
  end

  def toggle_user_subscription
    user.toggle_subscription!(subscribable, site)
  end

end
