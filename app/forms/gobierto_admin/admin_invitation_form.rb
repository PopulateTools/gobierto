# frozen_string_literal: true

module GobiertoAdmin
  class AdminInvitationForm < BaseForm

    EMAIL_LIST_DELIMITER = ","

    attr_accessor :emails, :site_ids

    validates :email_list, presence: true
    validates :site_ids, length: { minimum: 1, too_short: I18n.t("errors.messages.array_too_short") }

    def initialize(attributes = {})
      super(attributes)
      if @site_ids && @site_ids.any?
        @site_ids = @site_ids.delete_if { |site_id| site_id.blank? }.compact.uniq
      end
    end

    def process
      build_invitations if valid?
    end

    def delivered_email_addresses
      @delivered_email_addresses ||= []
    end

    def not_delivered_email_addresses
      Array(email_list) - delivered_email_addresses
    end

    private

    def email_list
      emails
        .split(EMAIL_LIST_DELIMITER)
        .select { |email| Admin::EMAIL_ADDRESS_REGEXP =~ email }
        .map(&:strip)
    end

    def build_invitations
      email_list.each do |email_address|
        invitation_builder = AdminInvitationBuilder.new(email_address, site_ids)

        if invitation_builder.call
          delivered_email_addresses.push(invitation_builder.email_address)
        end
      end
    end
  end
end
