class User::SubscriptionForm
  include ActiveModel::Model

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
    create_user_subscription if valid?
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
    @subscribable_type ||= @subscribable.try(:model_name)
  end

  def subscribable_id
    @subscribable_id ||= @subscribable.try(:id)
  end

  private

  def subscribable_class
    subscribable_type.try(:constantize)
  end

  def create_user_subscription
    user.subscribe_to!(subscribable, site)
  end

  def promote_errors(errors_hash)
    errors_hash.each do |attribute, message|
      errors.add(attribute, message)
    end
  end
end
