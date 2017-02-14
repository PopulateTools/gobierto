class User::SettingsForm
  include ActiveModel::Model

  attr_accessor(
    :user_id,
    :name,
    :password,
    :password_confirmation,
    :year_of_birth,
    :gender,
    :email
  )

  attr_reader :user

  validates :name, :year_of_birth, :gender, presence: true
  validates :password, confirmation: true
  validates :user, presence: true

  def save
    save_user_settings if valid?
  end

  def user
    @user ||= User.find_by(id: user_id)
  end

  private

  def save_user_settings
    @user = user.tap do |user_attributes|
      user_attributes.name = name
      user_attributes.password = password if password
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

  def promote_errors(errors_hash)
    errors_hash.each do |attribute, message|
      errors.add(attribute, message)
    end
  end
end
