class Admin::AdminInvitationForm
  include ActiveModel::Model

  EMAIL_LIST_DELIMITER = ",".freeze

  attr_accessor :admin_id, :emails, :site_ids

  validates :admin, :email_list, presence: true

  def process
    build_invitations if valid?
  end

  def admin
    @admin ||= Admin.find_by(id: admin_id)
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
