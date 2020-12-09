# frozen_string_literal: true

module Subscribers
  class AdminGobiertoDataActivity < ::Subscribers::Base

    def dataset_data_updated(event)
      create_activity_from_event(event, "dataset_data_updated")
    end

    def dataset_attribute_changed(event)
      create_activity_from_event(event, "dataset_updated")
    end

    def dataset_created(event)
      create_activity_from_event(event, "dataset_created")
    end

    def dataset_deleted(event)
      author = GobiertoAdmin::Admin.find_by id: event.payload[:admin_id]
      return unless author.present?

      action = "gobierto_data.dataset_dataset_deleted"
      Activity.create!(
        subject_type: "Site",
        subject_id: event.payload[:site_id],
        author: author,
        subject_ip: subject_ip(event, author),
        action: action,
        admin_activity: true,
        site_id: event.payload[:site_id]
      )
    end

    private

    def subject_ip(event, author)
      event.payload[:ip] || author.last_sign_in_ip || "127.0.0.1"
    end

    def create_activity_from_event(event, action)
      subject = GlobalID::Locator.locate event.payload[:gid]

      return unless subject.class.module_parent == GobiertoData

      author = GobiertoAdmin::Admin.find_by id: event.payload[:admin_id]

      # When the author is nil, we can asume the action has been performed by an integration
      return unless author.present?

      action = subject.class.name.underscore.tr("/", ".") + "." + action

      Activity.create! subject: subject,
                       author: author,
                       subject_ip: subject_ip(event, author),
                       action: action,
                       admin_activity: true,
                       site_id: event.payload[:site_id]
    end
  end
end
