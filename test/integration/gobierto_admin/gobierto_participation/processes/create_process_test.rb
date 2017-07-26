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

      def test_create_process_with_stages
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            click_link 'Nuevo proceso / grupo'

            within 'form.new_process' do
              fill_in 'process_title_translations_en', with: 'New process title'
              fill_in 'process_body_translations_en',  with: 'New process body'

              fill_in 'process_title_translations_es', with: 'Título del nuevo proceso'
              fill_in 'process_body_translations_es',  with: 'Descripción del nuevo proceso'

              fill_in 'process_slug', with: 'new-process'

              select 'Culture', from: 'process_issue_id'

              fill_in 'process_starts', with: '2017-01-01'
              fill_in 'process_ends',   with: '2017-01-30'

              choose 'process_process_type_process'

              # Activate and edit Information stage

              find('#process_stages_attributes_0_active').set(true)

              within '#edit_stage_0' do
                fill_in 'process_stages_attributes_0_title_translations_en', with: 'New information stage title'
                fill_in 'process_stages_attributes_0_description_translations_en', with: 'New information stage description'
                fill_in 'process_stages_attributes_0_starts', with: '2017-01-02'
                fill_in 'process_stages_attributes_0_ends',   with: '2017-01-14'
              end

              # Activate and edit Ideas stage

              find('#process_stages_attributes_2_active').set(true)

              within '#edit_stage_2' do
                fill_in 'process_stages_attributes_2_title_translations_en', with: 'New ideas stage title'
                fill_in 'process_stages_attributes_2_description_translations_en', with: 'New ideas stage description'
                fill_in 'process_stages_attributes_2_starts', with: '2017-01-20'
                fill_in 'process_stages_attributes_2_ends',   with: '2017-01-28'
              end

              click_button 'Create'
            end

            assert has_message? 'Process was successfully created'

            visit @path

            assert has_content? 'New process title'

            process = site.processes.process.last

            assert_equal 'New process title', process.title
            assert_equal 'New process body', process.body
            assert_equal 'Título del nuevo proceso', process.title_es
            assert_equal 'Descripción del nuevo proceso', process.body_es
            assert_equal 'new-process', process.slug
            assert_equal 'Culture', process.issue.name

            assert_equal 2, process.stages.size

            assert_equal 'New information stage title', process.stages.first.title
            assert_equal 'New ideas stage title', process.stages.last.title
          end
        end
      end

      def test_create_group
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            click_link 'Nuevo proceso / grupo'

            within 'form.new_process' do
              fill_in 'process_title_translations_en', with: 'New group title'
              fill_in 'process_body_translations_en',  with: 'New group body'

              fill_in 'process_slug', with: 'new-group'

              select 'Culture', from: 'process_issue_id'

              choose 'process_process_type_group_process'

              click_button 'Create'
            end

            assert has_message? 'Process was successfully created'

            visit @path

            assert has_content? 'New group title'

            group = site.processes.group_process.last

            assert_equal 'New group title', group.title
            assert_equal 'New group body', group.body
            assert_equal 'Culture', group.issue.name
            assert_nil group.starts
            assert_nil group.ends
          end
        end
      end

    end
  end
end
