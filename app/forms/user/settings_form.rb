# frozen_string_literal: true

class User::SettingsForm < BaseForm

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
  attr_writer(
    :user,
    :password_enabled,
    :read_only_user_attributes
  )

  validates :user, presence: true
  [:name, :date_of_birth, :gender].each do |attribute|
    validates attribute, presence: true, unless: -> { read_only_user_attributes.include?(attribute.to_s) }
  end
  validates :password, confirmation: true, if: :password_enabled

  def save
    save_user_settings if valid?
  end

  def password_enabled
    @password_enabled = true if @password_enabled.nil?
    @password_enabled
  end

  def user
    @user ||= User.find_by(id: user_id)
  end

  def site
    @site ||= user.site
  end

  def date_of_birth
    @date_of_birth ||= if date_of_birth_year && date_of_birth_month && date_of_birth_day
                         Date.new(date_of_birth_year.to_i, date_of_birth_month.to_i, date_of_birth_day.to_i)
                       end
  rescue ArgumentError
    nil
  end

  def disabled_user_attribute?(attribute)
    read_only_user_attributes.include? attribute.to_s
  end

  def read_only_user_attributes
    @read_only_user_attributes ||= []
  end

  private

  def save_user_settings
    @user = user.tap do |user_attributes|
      user_attributes.name = name unless disabled_user_attribute?(:name)
      user_attributes.password = password if password && password_enabled
      user_attributes.date_of_birth = date_of_birth unless disabled_user_attribute?(:date_of_birth)
      user_attributes.gender = gender unless disabled_user_attribute?(:gender)
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

end
