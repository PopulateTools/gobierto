module GobiertoAdmin
  class AdminNotificationBuilder
    attr_reader :event_name, :module_name, :subject, :payload, :site, :admin

    def initialize(event)
      @subject = GlobalID::Locator.locate(event.payload[:gid])
      @event_name = event.name.split(".").last
      @module_name = subject.class.name.split("::").first
      @payload = event.payload
      @admin = GobiertoAdmin::Admin.find(payload[:admin_id])
      @site = Site.find(payload[:site_id])
    end

    def call
      recipients.each do |recipient|
        next unless admin_actions_manager.action_allowed?(admin: recipient, action_name: payload[:allowed_actions_to_send_notification], resource: subject)

        deliver_notification(recipient)
      end
    end

    def recipients
      assigned_users = GobiertoAdmin::Admin.joins(:admin_group_memberships).where(admin_groups_admins: { admin_group_id: GobiertoAdmin::AdminGroup.where(resource: subject) })
      author = subject.try(:author)
      return assigned_users.distinct if author.blank?

      assigned_users.or(GobiertoAdmin::Admin.where(id: author.id)).distinct
    end

    private

    def admin_actions_manager
      @admin_actions_manager ||= GobiertoAdmin::AdminActionsManager.for(@module_name, @site)
    end

    def deliver_notification(recipient)
      mailer_class.send(event_name, subject, recipient, payload).deliver_later
    end

    def mailer_class
      ::GobiertoAdmin.const_get("#{module_name}::AdminMailer")
    end
  end
end
