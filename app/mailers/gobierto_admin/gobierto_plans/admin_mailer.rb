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
        allowed_actions = permissions_policy(project:).allowed_actions
        @project_url = if allowed_actions.include?(:edit)
                         edit_admin_plans_plan_project_url(@project, plan_id: @plan.id, host: @site_host)
                       else
                         admin_plans_plan_projects_url(@plan, host: @site_host)
                       end
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
        allowed_actions = permissions_policy(project:).allowed_actions
        @project_url = if allowed_actions.include?(:edit)
                         edit_admin_plans_plan_project_url(@project, plan_id: @plan.id, host: @site_host)
                       else
                         admin_plans_plan_projects_url(@plan, host: @site_host)
                       end
        mail(
          from:,
          reply_to:,
          to: @recipient.email,
          subject: t(".subject", site_name: @site.name, plan_title: @plan.title)
        )
      end

      def project_deleted(plan, recipient, payload = {})
        @plan = plan
        @recipient = recipient
        @site = @plan.site
        @site_host = site_host
        @project_name = payload[:project_name]
        @payload = payload
        @plan_url = admin_plans_plan_projects_url(@plan, host: @site_host)

        mail(
          from:,
          reply_to:,
          to: @recipient.email,
          subject: t(".subject", site_name: @site.name, plan_title: @plan.title)
        )
      end

      def permissions_policy(**resource_param)
        GobiertoAdmin::GobiertoPlans::ProjectPolicy.new(
          current_admin: @recipient,
          current_site: @site,
          **resource_param
        )
      end
    end
  end
end
