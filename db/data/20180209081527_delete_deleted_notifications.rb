# frozen_string_literal: true

class DeleteDeletedNotifications < ActiveRecord::Migration[5.1]
  def up
    ::User::Notification.where(action: "gobierto_attachments.attachment.name_changed").destroy_all
    ::User::Notification.where(action: "gobierto_attachments.attachment.updated").destroy_all
    ::User::Notification.where(action: "gobierto_participation.process.updated").destroy_all
    ::User::Notification.where(action: "issue.description_translations_changed").destroy_all
    ::User::Notification.where(action: "gobierto_cms.page.updated").destroy_all
    ::User::Notification.where(action: "gobierto_participation.process.published").destroy_all
    ::User::Notification.where(action: "gobierto_cms.page.published").destroy_all
    ::User::Notification.where(action: "gobierto_calendars.event.published").destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
