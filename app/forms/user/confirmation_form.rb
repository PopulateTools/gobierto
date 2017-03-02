class User::ConfirmationForm
  include ActiveModel::Model
  include GobiertoCommon::CustomUserFieldsHelper

  attr_accessor(
    :confirmation_token,
    :name,
    :password,
    :password_confirmation,
    :date_of_birth_year,
    :date_of_birth_month,
    :date_of_birth_day,
    :date_of_birth,
    :gender
  )
  attr_reader :user

  validates :name, :date_of_birth, :gender, :user, presence: true
  validates :password, presence: true, confirmation: true

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

  def site
    @site ||= user.source_site if user
  end

  def date_of_birth
    @date_of_birth ||= if date_of_birth_year && date_of_birth_month && date_of_birth_day
      Date.new(
        date_of_birth_year.to_i,
        date_of_birth_month.to_i,
        date_of_birth_day.to_i
      )
    end
  rescue ArgumentError
    nil
  end

  private

  def save_user
    @user = user.tap do |user_attributes|
      user_attributes.name = name
      user_attributes.password = password
      user_attributes.date_of_birth = date_of_birth
      user_attributes.gender = gender
      user_attributes.custom_records = custom_records
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
    enable_notifications
  end

  protected

  def promote_errors(errors_hash)
    errors_hash.each do |attribute, message|
      errors.add(attribute, message)
    end
  end

  def deliver_welcome_email
    if user
      User::UserMailer.welcome(user, user.source_site).deliver_later
    end
  end

  def enable_notifications
    user.immediate_notifications!
  end
end
