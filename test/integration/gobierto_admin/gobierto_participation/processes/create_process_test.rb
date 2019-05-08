# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    class CreateProcessTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_participation_path
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

              click_link "New"

              fill_in "process_title_translations_en", with: "New process title"
              page.execute_script('document.getElementById("process_body_translations_en").value = "New process body"')

              switch_locale "ES"

              fill_in "process_title_translations_es", with: "Título del nuevo proceso"

              page.execute_script('document.getElementById("process_body_translations_es").value = "Descripción del nuevo proceso"')

              fill_in "process_slug", with: ""

              select "Culture", from: "process_issue_id"

              select "Old town", from: "process_scope_id"

              find("#process_has_duration", visible: false).execute_script("this.click()")

              fill_in "process_starts", with: "2017-01-01"
              fill_in "process_ends", with: "2017-01-30"

              find("#process_process_type_process", visible: false).execute_script("this.click()")

              click_button "Create"

              assert has_message? "Process was successfully created"

              process = site.processes.process.last

              assert_equal "New process title", process.title
              assert_equal "New process body", process.body
              assert_equal "Título del nuevo proceso", process.title_es
              assert_equal "Descripción del nuevo proceso", process.body_es
              assert_equal "Culture", process.issue.name
              assert_equal "Old town", process.scope.name

              # check slug gets auto-filled in server
              assert_equal "new-process-title", process.slug

              # check information stage are created
              assert_equal 1, process.stages.size

              activity = Activity.last
              assert_equal process, activity.subject
              assert_equal admin, activity.author
              assert_equal site.id, activity.site_id
              assert_equal "gobierto_participation.process_created", activity.action
            end
          end
        end
      end
    end
  end
end
