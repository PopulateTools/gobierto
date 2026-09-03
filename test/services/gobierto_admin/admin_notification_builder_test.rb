# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class AdminNotificationBuilderTest < ActiveSupport::TestCase
    # AdminNotificationBuilder only reads the name and the payload of the
    # published event, so a plain double keeps the test away from pub/sub setup.
    Event = Struct.new(:name, :payload)

    attr_reader :site, :project, :recipient, :author

    def setup
      @site = sites(:madrid)
      @project = gobierto_plans_nodes(:political_agendas)
      # tony belongs to the system group of the project, which makes him a
      # recipient candidate; the module level group grants him view_projects.
      @recipient = gobierto_admin_admins(:tony)
      @author = gobierto_admin_admins(:steve)
      GroupsAdmin.create!(admin: recipient, admin_group: gobierto_admin_admin_groups(:madrid_view_all_projects_group))
    end

    def event(event_name = "project_attributes_changed")
      Event.new(
        "admin_trackable.#{event_name}",
        {
          gid: project.to_gid,
          site_id: site.id,
          admin_id: author.id,
          allowed_actions_to_send_notification: [:view_projects, :edit_projects]
        }
      )
    end

    def builder(event_name = "project_attributes_changed")
      AdminNotificationBuilder.new(event(event_name))
    end

    def teardown
      ActionMailer::Base.deliveries.clear
    end

    def test_delivers_notification_to_allowed_recipients
      assert_difference "ActionMailer::Base.deliveries.size", 1 do
        builder.call
      end

      assert_equal [recipient.email], ActionMailer::Base.deliveries.last.to
    end

    def test_does_not_deliver_notification_when_recipient_opted_out_from_the_module
      recipient.update!(notification_settings: { "gobierto_plans" => false })

      %w(project_created project_attributes_changed).each do |event_name|
        assert_no_difference "ActionMailer::Base.deliveries.size" do
          builder(event_name).call
        end
      end
    end

    def test_delivers_notification_when_the_recipient_enabled_the_module
      recipient.update!(notification_settings: { "gobierto_plans" => true })

      assert_difference "ActionMailer::Base.deliveries.size", 1 do
        builder.call
      end
    end

    # The recipient stays in the project group, so he is still a candidate, but
    # without the module level permission the notification must not be sent.
    def test_does_not_deliver_notification_when_action_is_not_allowed
      GroupsAdmin.where(admin: recipient, admin_group: gobierto_admin_admin_groups(:madrid_view_all_projects_group)).delete_all
      recipient.reload

      assert_includes AdminNotificationBuilder.new(event).recipients, recipient

      assert_no_difference "ActionMailer::Base.deliveries.size" do
        builder.call
      end
    end
  end
end
