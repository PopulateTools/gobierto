class User::RegistrationForm
  include ActiveModel::Model

  attr_accessor(
    :email,
    :site,
    :creation_ip
  )

  validates :site, presence: true
  validates :email, format: { with: User::EMAIL_ADDRESS_REGEXP }

  def save
    return false unless valid?

    send_confirmation_instructions if save_user
  end

  def user
    @user ||= User.new
  end

  private

  def save_user
    @user = user.tap do |user_attributes|
      user_attributes.email = email
      user_attributes.source_site = site
      user_attributes.creation_ip = creation_ip
    end

    if @user.valid?
      @user.save

      @user
    else
      promote_errors(@user.errors)

      false
    end
  end

  def send_confirmation_instructions
    user.regenerate_confirmation_token
    deliver_confirmation_email
  end

  protected

  def promote_errors(errors_hash)
    errors_hash.each do |attribute, message|
      errors.add(attribute, message)
    end
  end

  def deliver_confirmation_email
    User::UserMailer.confirmation_instructions(user, site).deliver_later
  end
end
