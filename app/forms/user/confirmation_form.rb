class User::ConfirmationForm
  include ActiveModel::Model

  attr_accessor(
    :confirmation_token,
    :name,
    :password,
    :password_confirmation,
    :year_of_birth,
    :gender
  )
  attr_reader :user

  validates :name, :year_of_birth, :gender, presence: true
  validates :password, presence: true, confirmation: true
  validates :user, presence: true

  def save
    return false unless valid?

    confirm_user if save_user
  end

  def user
    @user ||= User.find_by_confirmation_token(confirmation_token)
  end

  def email
    @email ||= user.email
  end

  private

  def save_user
    @user = user.tap do |user_attributes|
      user_attributes.name = name
      user_attributes.password = password
      user_attributes.year_of_birth = year_of_birth
      user_attributes.gender = gender
    end

    if @user.valid?
      @user.save

      @user
    else
      promote_errors(@user.errors)

      false
    end
  end

  def confirm_user
    user.confirm!
    deliver_welcome_email
  end

  protected

  def promote_errors(errors_hash)
    errors_hash.each do |attribute, message|
      errors.add(attribute, message)
    end
  end

  def deliver_welcome_email
    User::UserMailer.welcome(user, user.source_site).deliver_later
  end
end
