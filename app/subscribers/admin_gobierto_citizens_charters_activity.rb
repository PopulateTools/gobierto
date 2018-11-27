# frozen_string_literal: true

module Subscribers
  class AdminGobiertoCitizensChartersActivity < ::Subscribers::Base

    def editions_edition_attribute_changed(event)
      create_activity_from_event(event, "edition_updated")
    end

    def editions_created(event)
      create_activity_from_event(event, "edition_created")
    end

    def editions_deleted(event)
      create_activity_from_event(event, "edition_deleted")
    end

    def commitments_commitment_attribute_changed(event)
      create_activity_from_event(event, "commitment_updated")
    end

    def commitments_visibility_level_changed(event)
      create_activity_from_event(event, "commitment_published")
    end

    def commitments_created(event)
      create_activity_from_event(event, "commitment_created")
    end

    def commitments_archived(event)
      create_activity_from_event(event, "commitment_archived")
    end

    def charter_attribute_changed(event)
      create_activity_from_event(event, "updated")
    end

    def service_attribute_changed(event)
      create_activity_from_event(event, "updated")
    end

    def visibility_level_changed(event)
      create_activity_from_event(event, "published")
    end

    def created(event)
      create_activity_from_event(event, "created")
    end

    def archived(event)
      create_activity_from_event(event, "archived")
    end

    private

    def create_activity_from_event(event, action)
      subject = GlobalID::Locator.locate event.payload[:gid]

      return unless subject.class.parent == GobiertoCitizensCharters

      author = GobiertoAdmin::Admin.find_by id: event.payload[:admin_id]
      # When the author is nil, we can asume the action has been performed by an integration
      return unless author.present?

      action = subject.class.name.underscore.tr("/", ".") + "." + action

      Activity.create! subject: subject,
                       author: author,
                       subject_ip: author.last_sign_in_ip,
                       action: action,
                       admin_activity: true,
                       site_id: event.payload[:site_id]
    end
  end
end
