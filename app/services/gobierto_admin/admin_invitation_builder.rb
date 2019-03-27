# frozen_string_literal: true

module GobiertoAdmin
  class AdminInvitationBuilder
    attr_reader :email_address, :sites, :admin

    def initialize(email_address, site_ids = [])
      @email_address = email_address
      @sites = Site.where(id: site_ids)
    end

    def call
      deliver_invitation_email if create_admin
    end

    private

    def create_admin
      @admin = Admin.create!(
        email: email_address,
        name: get_username_from_email(email_address),
        password: generate_random_password,
        invitation_token: Admin.generate_unique_secure_token,
        invitation_sent_at: Time.zone.now
      )
      @admin.sites = sites

      @admin
    rescue ActiveRecord::RecordInvalid
      false
    end

    def deliver_invitation_email
      AdminMailer.invitation_instructions(admin).deliver_later
    end

    protected

    def get_username_from_email(email_address)
      if email_address =~ Admin::EMAIL_ADDRESS_REGEXP
        $1
      end
    end

    def generate_random_password
      SecureRandom.hex(8)
    end
  end
end
