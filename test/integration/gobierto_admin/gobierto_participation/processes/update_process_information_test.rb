# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    class UpdateProcessInformationTest < ActionDispatch::IntegrationTest
      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def process
        site.processes.process.first
      end

      def test_update_process_information
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_participation_process_path(process)

            click_on "Information"

            within "form.edit_process" do
              fill_in "process[information_text_translations][en]", with: "Edited information text"

              click_button "Update"
            end

            assert has_message? "Process was successfully updated"

            visit edit_admin_participation_process_path(process)

            click_on "Information"

            assert has_content? "Edited information text"
          end
        end
      end
    end
  end
end
