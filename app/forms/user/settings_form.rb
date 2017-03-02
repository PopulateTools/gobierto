class User::SettingsForm
  include ActiveModel::Model
  include GobiertoCommon::CustomUserFieldsHelper

  attr_accessor(
    :user_id,
    :name,
    :password,
    :password_confirmation,
    :date_of_birth_year,
    :date_of_birth_month,
    :date_of_birth_day,
    :gender,
    :email
  )

  attr_reader :user

  validates :name, :date_of_birth, :gender, :user, presence: true
  validates :password, confirmation: true

  def save
    save_user_settings if valid?
  end

  def user
    @user ||= User.find_by(id: user_id)
  end

  def site
    @site ||= user.source_site
  end

  def date_of_birth
    @date_of_birth ||= if date_of_birth_year && date_of_birth_month && date_of_birth_day
      Date.new(date_of_birth_year.to_i, date_of_birth_month.to_i, date_of_birth_day.to_i)
    end
  rescue ArgumentError
    nil
  end

  private

  def save_user_settings
    @user = user.tap do |user_attributes|
      user_attributes.name = name
      user_attributes.password = password if password
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

  def promote_errors(errors_hash)
    errors_hash.each do |attribute, message|
      errors.add(attribute, message)
    end
  end
end
