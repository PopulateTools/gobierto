# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  module GobiertoParticipation
    class CreateProcessTest < ActionDispatch::IntegrationTest

      def setup
        super
        @path = admin_participation_processes_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_create_process
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              click_link 'New process / group'

              fill_in 'process_title_translations_en', with: 'New process title'
              fill_in 'process_body_translations_en', with: 'New process body'

              click_link 'ES'

              fill_in 'process_title_translations_es', with: 'Título del nuevo proceso'
              fill_in 'process_body_translations_es', with: 'Descripción del nuevo proceso'

              select 'Culture', from: 'process_issue_id'

              select 'Old town', from: 'process_scope_id'

              find('#process_has_duration', visible: false).trigger(:click)

              fill_in 'process_starts', with: '2017-01-01'
              fill_in 'process_ends', with: '2017-01-30'

              find('#process_process_type_process', visible: false).trigger(:click)

              click_button 'Create'

              assert has_message? 'Process was successfully created'

              visit @path

              assert has_content? 'New process title'

              process = site.processes.process.last

              assert_equal 'New process title', process.title
              assert_equal 'New process body', process.body
              assert_equal 'Título del nuevo proceso', process.title_es
              assert_equal 'Descripción del nuevo proceso', process.body_es
              assert_equal 'Culture', process.issue.name
              assert_equal 'Old town', process.scope.name

              # check slug gets auto-filled in server
              assert_equal 'new-process-title', process.slug
              
              # check empty stages are created
              assert_equal ::GobiertoParticipation::ProcessStage.stage_types.keys.size, process.stages.size
            end
          end
        end
      end

    end
  end
end
