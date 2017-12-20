# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  module GobiertoParticipation
    class CreateProcessTest < ActionDispatch::IntegrationTest

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def process
        @process ||= gobierto_participation_processes(:gender_violence_process)
      end

      def group
        @group ||= gobierto_participation_processes(:green_city_group)
      end

      def test_update_process
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_participation_process_path(process)

            within 'form.edit_process' do
              fill_in 'process_title_translations_en', with: 'Edited process title'
              select 'Women', from: 'process_issue_id'
              select 'Center', from: 'process_scope_id'

              click_button 'Update'
            end

            assert has_message? 'Process was successfully updated'

            visit admin_participation_path

            assert has_content? 'Edited process title'

            process.reload

            assert_equal 'Edited process title', process.title
            assert_equal 'Women', process.issue.name
            assert_equal 'Center', process.scope.name
          end
        end
      end

      def test_update_group
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_participation_process_path(group)

            within 'form.edit_process' do
              fill_in 'process_title_translations_en', with: 'Edited group title'
              select 'Women', from: 'process_issue_id'
              select 'Center', from: 'process_scope_id'

              click_button 'Update'
            end

            assert has_message? 'Process was successfully updated'

            visit admin_participation_path

            assert has_content? 'Edited group title'

            group.reload

            assert_equal 'Edited group title', group.title
            assert_equal 'Women', group.issue.name
            assert_equal 'Center', group.scope.name
          end
        end
      end

      def test_update_process_adding_new_stages
        skip 'Add new process stage'
      end

      def test_update_process_deleting_existing_stages
        skip 'Delete process stage'
      end

      def test_update_process_editing_existing_stages
        skip 'Update process stage'
      end
    end
  end
end
