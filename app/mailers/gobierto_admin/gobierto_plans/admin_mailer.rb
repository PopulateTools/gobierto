module GobiertoAdmin
  module GobiertoPlans
    class AdminMailer < ApplicationMailer
      def project_attributes_changed(project, recipient, payload = {})
        @project = project
        @plan = @project.plan
        @recipient = recipient
        @site = @plan.site
        @site_host = site_host
        @payload = payload

        mail(
          from:,
          reply_to:,
          to: @recipient.email,
          subject: t(".subject", site_name: @site.name, plan_title: @plan.title)
        )
      end

      def project_created(project, recipient, payload = {})
        @project = project
        @plan = @project.plan
        @recipient = recipient
        @site = @plan.site
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
