# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    module ProcessStages
      class PreviewTest < ActionDispatch::IntegrationTest

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def site
          @site ||= sites(:madrid)
        end

        def process
          @process ||= gobierto_participation_processes(:complete_process)
        end

        def process_stages
          @process_stages ||= process.stages
        end

        def test_preview_document
          with_signed_in_admin(admin) do
            with_current_site(site) do
              process_stages.each do |process_stage|
                process.active!

                visit admin_participation_process_process_stages_path(process)

                within "#process-stage-item-#{process_stage.id}" do
                  click_link "Manage"
                end

                assert preview_link_excludes_token?
                click_preview_link

                assert_equal process_stage.to_url, current_url

                process.draft!

                visit admin_participation_process_process_stages_path(process)

                within "#process-stage-item-#{process_stage.id}" do
                  click_link "Manage"
                end

                assert preview_link_includes_token?
                click_preview_link

                assert_equal process_stage.to_url(preview: true, admin: admin), current_url
              end
            end
          end
        end

      end
    end
  end
end
