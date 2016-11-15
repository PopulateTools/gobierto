class Admin::AdminInvitationForm
  include ActiveModel::Model

  EMAIL_LIST_DELIMITER = ",".freeze

  attr_accessor :emails, :site_ids

  validates :email_list, presence: true

  def process
    build_invitations if valid?
  end

  def site_ids
    @site_ids ||= []
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
      Admin::AdminInvitationBuilder.new(email_address, site_ids).call
    end
  end
end
