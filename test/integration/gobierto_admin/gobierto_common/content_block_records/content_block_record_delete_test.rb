# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    module ContentBlockRecords
      class ContentBlockRecordTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = edit_admin_people_person_path(gobierto_people_people(:richard))
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def site
          @site ||= sites(:madrid)
        end

        def accomplishments_content_block
          "div[data-title='Accomplishments']"
        end

        def test_content_block_record_delete
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                # Delete second record

                within accomplishments_content_block do
                  delete_links = all("a[data-behavior=delete_record]", visible: false)
                  delete_links[1].execute_script("this.click()")
                end

                click_button "Update"

                within accomplishments_content_block do
                  assert has_content? "Nobel Prize in Chemistry"
                  assert has_content? "nobel_prize.pdf"

                  assert has_no_content? "Ran New York marathon"
                  assert has_no_content? "marathon_certificate.pdf"

                  assert has_content? "Ate 33 meatballs in 45 minutes"
                end
              end
            end
          end
        end
      end
    end
  end
end
