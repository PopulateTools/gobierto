class ApplicationMailer < ActionMailer::Base
  layout "mailer"

  private

  def from
    if @site
      @site.organization_email.presence || default_organization_address
    else
      default_from
    end
  end

  def default_organization_address
    "#{@site.name} <no-reply@#{site_host}>"
  end

  def site_host
    @site.try(:domain) || ENV["HOST"]
  end

  def default_from
    APP_CONFIG["email_config"]["default_from"]
  end
end
