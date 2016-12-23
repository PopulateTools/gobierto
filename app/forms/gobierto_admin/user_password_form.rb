module GobiertoAdmin
  class UserPasswordForm
    include ActiveModel::Model

    attr_accessor(
      :id,
      :password,
      :password_confirmation
    )

    validates :user, :password, presence: true
    validates :password, confirmation: true

    def save
      save_user if valid?
    end

    def user
      @user ||= User.find_by(id: id).presence || build_user
    end

    private

    def build_user
      User.new
    end

    def save_user
      @user = user.tap do |user_attributes|
        user_attributes.password = password if password
      end

      if @user.valid?
        @user.save

        @user
      else
        promote_errors(@user.errors)

        false
      end
    end

    protected

    def promote_errors(errors_hash)
      errors_hash.each do |attribute, message|
        errors.add(attribute, message)
      end
    end
  end
end
