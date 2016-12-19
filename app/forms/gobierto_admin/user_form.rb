module GobiertoAdmin
  class UserForm
    include ActiveModel::Model

    attr_accessor(
      :id,
      :name,
      :bio,
      :email
    )

    delegate :persisted?, to: :user

    validates :user, :name, presence: true
    validates :email, format: { with: User::EMAIL_ADDRESS_REGEXP }

    def save
      return false unless valid?

      if save_user
        send_confirmation_instructions if email_changed?

        user
      end
    end

    def user
      @user ||= User.find_by(id: id).presence || build_user
    end

    private

    def build_user
      User.new
    end

    def email_changed?
      @email_changed
    end

    def save_user
      @user = user.tap do |user_attributes|
        user_attributes.name = name   if name
        user_attributes.bio = bio     if bio
        user_attributes.email = email if email
      end

      # Check changes
      @email_changed = @user.email_changed?

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
      UserMailer.confirmation_instructions(user, user.source_site).deliver_later
    end
  end
end
