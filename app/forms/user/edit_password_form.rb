class User::EditPasswordForm
  include ActiveModel::Model

  attr_accessor :user_id, :password, :password_confirmation
  attr_reader :user

  validates :user, :password, presence: true
  validates :password, confirmation: true

  def save
    update_password if valid?
  end

  def user
    @user ||= User.find_by(id: user_id)
  end

  def password
    @password || ""
  end

  def password_confirmation
    @password_confirmation || ""
  end

  private

  def update_password
    @user.update_attributes(password: password)
  end
end
