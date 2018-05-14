# frozen_string_literal: true

module GobiertoAdmin
  class AdminSettingsForm < BaseForm

    attr_accessor(
      :id,
      :name,
      :email,
      :password,
      :password_confirmation
    )

    delegate :persisted?, to: :admin

    validates :name, :email, presence: true
    validates :email, format: { with: Admin::EMAIL_ADDRESS_REGEXP }
    validates :password, confirmation: true

    def save
      @new_record = admin.new_record?

      return false unless valid?

      if save_admin
        admin
      end
    end

    def admin
      @admin ||= Admin.find_by(id: id)
    end

    private

    def save_admin
      @admin = admin.tap do |admin_attributes|
        admin_attributes.name = name
        admin_attributes.email = email
        admin_attributes.password = password if password
      end

      if @admin.valid?
        ActiveRecord::Base.transaction do
          @admin.save unless persisted?
          @admin.save
        end

        @admin
      else
        promote_errors(@admin.errors)

        false
      end
    end

  end
end
