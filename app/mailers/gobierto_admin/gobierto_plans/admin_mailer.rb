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
        @changes = changes_list(@project, @payload)
        basic_changes = @changes.values.compact
        subject = if basic_changes.present?
                    t(".subject_with_changes", site_name: @site.name, plan_title: @plan.title, changes: basic_changes.to_sentence)
                  else
                    t(".subject", site_name: @site.name, plan_title: @plan.title)
                  end
        mail(
          from:,
          reply_to:,
          to: @recipient.email,
          subject:
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

      def changes_list(project, payload)
        changes = {}
        if payload[:visibility_level_change]
          changes[:visibility_level_change] = t(
            project.visibility_level,
            scope: "gobierto_admin.gobierto_plans.admin_mailer.project_attributes_changed.visibility_levels"
          )
        end
        if payload[:moderation_stage_change]
          changes[:moderation_stage_change] = t(
            project.moderation_stage,
            scope: "gobierto_admin.shared.moderation_save_widget.moderation_status"
          )
        end
        if payload[:edition_change]
          changes[:edition_change] = nil
        end
        changes
      end
    end
  end
end
