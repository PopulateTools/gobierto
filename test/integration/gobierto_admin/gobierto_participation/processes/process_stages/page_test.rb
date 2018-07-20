# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      module ProcessStages
        class PageTest < ActionDispatch::IntegrationTest

          def admin
            @admin ||= gobierto_admin_admins(:nick)
          end

          def site
            @site ||= sites(:madrid)
          end

          def gender_violence_process
            @gender_violence_process ||= gobierto_participation_processes(:gender_violence_process)
          end

          def bowling_group_very_active
            @bowling_group_very_active ||= gobierto_participation_processes(:bowling_group_very_active)
          end

          def information_stage_with_page
            @information_stage_with_page ||= gobierto_participation_process_stages(:gender_violence_process_information_stage)
          end

          def information_stage_without_page
            @information_stage_without_page ||= gobierto_participation_process_stages(:bowling_group_information_stage)
          end

          def cms_page
            @cms_page ||= gobierto_cms_pages(:notice_1)
          end

          def test_create_process_stage_page
            with_signed_in_admin(admin) do
              with_current_site(site) do

                visit admin_participation_process_process_stages_path(bowling_group_very_active)

                within "#process-stage-item-#{information_stage_without_page.id}" do
                  click_link "Manage"
                end

                new_process_stage_page_path = new_admin_participation_process_process_stage_process_stage_page_path(
                  process_id: bowling_group_very_active.id,
                  process_stage_id: information_stage_without_page.id
                )

                assert_equal new_process_stage_page_path, current_path

                select cms_page.title, from: "process_stage_page_page_id"

                click_button "Create"

                selected_page_id = find("#process_stage_page_page_id").value.to_i
                assert_equal cms_page.id, selected_page_id
              end
            end
          end

          def test_update_process_stage_page
            with_signed_in_admin(admin) do
              with_current_site(site) do

                visit admin_participation_process_process_stages_path(gender_violence_process)

                within "#process-stage-item-#{information_stage_with_page.id}" do
                  click_link "Manage"
                end

                select cms_page.title, from: "process_stage_page_page_id"

                click_button "Update"

                selected_page_id = find("#process_stage_page_page_id").value.to_i
                assert_equal cms_page.id, selected_page_id
              end
            end
          end

        end
      end
    end
  end
end
