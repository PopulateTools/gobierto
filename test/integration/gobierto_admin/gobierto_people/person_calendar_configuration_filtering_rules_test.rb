# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/authorizable_resource_test_module"

module GobiertoAdmin
  module GobiertoPeople
    class PersonCalendarConfigurationFilteringRulesTest < ActionDispatch::IntegrationTest
      include ::GobiertoAdmin::AuthorizableResourceTestModule

      def setup
        super
        @person_events_path = admin_calendars_events_path(collection_id: person.events_collection.id)
        setup_authorizable_resource_test(gobierto_admin_admins(:steve), @person_events_path)
       end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def tony
        @tony ||= gobierto_admin_admins(:tony)
      end
      alias regular_admin_with_permissions tony

      def steve
        @steve ||= gobierto_admin_admins(:steve)
      end
      alias regular_admin_without_permissions steve

      def site
        @site ||= sites(:madrid)
      end

      def test_create_and_update_filtering_rules
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @person_events_path

              click_link 'Agenda'
              click_link 'Configuration'

              select "Title", from: "calendar_configuration_filtering_rules_attributes_0_field"
              select "Contains", from: "calendar_configuration_filtering_rules_attributes_0_condition"
              fill_in "calendar_configuration_filtering_rules_attributes_0_value", with: "@"
              select "Ignore", from: "calendar_configuration_filtering_rules_attributes_0_action"

              click_link "Create rule"

              new_node_id = page.all('.dynamic-content-record-form').last.all('select').first[:id].match(/\d+/)[0]

              select "Title", from: "calendar_configuration_filtering_rules_attributes_#{new_node_id}_field"
              select "Contains", from: "calendar_configuration_filtering_rules_attributes_#{new_node_id}_condition"
              fill_in "calendar_configuration_filtering_rules_attributes_#{new_node_id}_value", with: "[draft]"
              select "Ignore", from: "calendar_configuration_filtering_rules_attributes_#{new_node_id}_action"

              click_button "Update"

              assert has_message?("Settings updated successfully")

              assert_equal 2, page.all('#filtering-rules tbody.dynamic-content-record-wrapper').size
            end
          end
        end
      end

      def test_delete_filtering_rules
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @person_events_path

              click_link 'Agenda'
              click_link 'Configuration'

              page.find('[data-behavior="delete_record"]').click

              click_button "Update"

              assert has_message?("Settings updated successfully")

              assert_equal 1, page.all('#filtering-rules tbody.dynamic-content-record-wrapper').size
            end
          end
        end
      end
    end
  end
end
