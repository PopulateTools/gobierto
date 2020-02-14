class ApplicationMailer < ActionMailer::Base
  layout "mailer"

  private

  def from
    @site.organization_email.presence || default_organization_address
  end

  def default_organization_address
    "#{@site.name} <no-reply@#{site_host}>"
  end

  def site_host
    @site.try(:domain) || ENV["HOST"]
  end
end
