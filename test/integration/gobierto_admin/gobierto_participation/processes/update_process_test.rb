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
        site.processes.process.first
      end

      def group
        site.processes.group_process.first
      end

      def test_update_process
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_participation_process_path(process)

            within 'form.edit_process' do
              fill_in 'process_title_translations_en', with: 'Edited process title'
              select 'Women', from: 'process_issue_id'

              click_button 'Update'
            end

            assert has_message? 'Process was successfully updated'

            visit admin_participation_processes_path

            assert has_content? 'Edited process title'

            assert_equal 'Edited process title', process.title
            assert_equal 'Women', process.issue.name
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

              click_button 'Update'
            end

            assert has_message? 'Process was successfully updated'

            visit admin_participation_processes_path

            assert has_content? 'Edited group title'

            assert_equal 'Edited group title', group.title
            assert_equal 'Women', group.issue.name
          end
        end
      end

      def test_update_process_adding_new_stages
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_participation_process_path(process)

            # Add Results stage
            within 'form.edit_process' do
              find('#process_stages_attributes_4_active').set(true)

              within '#edit_stage_4' do
                fill_in 'process_stages_attributes_4_title_translations_en', with: 'Results stage title'
                fill_in 'process_stages_attributes_4_starts', with: '2017-01-02'
                fill_in 'process_stages_attributes_4_ends',   with: '2017-01-14'
              end

              click_button 'Update'
            end

            assert has_message? 'Process was successfully updated'

            visit admin_participation_processes_path

            assert array_match %w(information meetings ideas results), process.stages.pluck(:stage_type)
          end
        end
      end

      def test_update_process_deleting_existing_stages
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_participation_process_path(process)

            within 'form.edit_process' do
              find('#process_stages_attributes_0_active').set(false)  # disable Information stage
              click_button 'Update'
            end

            assert has_message? 'Process was successfully updated'

            visit admin_participation_processes_path

            assert array_match %w(meetings ideas), process.stages.pluck(:stage_type)
          end
        end
      end

      def test_update_process_editing_existing_stages
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_participation_process_path(process)

            within 'form.edit_process' do

              # Update Information stage
              within '#edit_stage_0' do
                fill_in 'process_stages_attributes_0_title_translations_en', with: 'Edited information stage title'
                fill_in 'process_stages_attributes_0_starts', with: '2017-07-15'
                fill_in 'process_stages_attributes_0_ends',   with: '2017-07-16'
              end

              # Update Meetings stage
              within '#edit_stage_1' do
                fill_in 'process_stages_attributes_1_title_translations_en', with: 'Edited meetings stage title'
                fill_in 'process_stages_attributes_1_starts', with: '2017-08-17'
                fill_in 'process_stages_attributes_1_ends',   with: '2017-08-18'
              end

              click_button 'Update'
            end

            assert has_message? 'Process was successfully updated'

            visit admin_participation_processes_path

            information_stage = process.stages.find_by(stage_type: 'information')
            meetings_stage    = process.stages.find_by(stage_type: 'meetings')

            assert array_match %w(information meetings ideas), process.stages.pluck(:stage_type)

            assert_equal 'Edited information stage title', information_stage.title
            assert_equal Date.parse('2017-07-15'), information_stage.starts
            assert_equal Date.parse('2017-07-16'), information_stage.ends

            assert_equal 'Edited meetings stage title', meetings_stage.title
            assert_equal Date.parse('2017-08-17'), meetings_stage.starts
            assert_equal Date.parse('2017-08-18'), meetings_stage.ends
          end
        end
      end

    end
  end
end
