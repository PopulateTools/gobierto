module GobiertoAdmin
  module GobiertoPlans
    class AdminMailer < ApplicationMailer
      def project_attributes_changed(project, plan, recipient, payload = {})
        @project = project
        @plan = plan
        @recipient = recipient
        @site = plan.site
        @site_host = site_host
        @payload = payload

        mail(
          from:,
          reply_to:,
          to: @recipient.email,
          subject: t(".subject", site_name: @site.name, plan_title: @plan.title)
        )
      end
    end
  end
end
