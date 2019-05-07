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

        def test_content_block_record_update_records
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                within accomplishments_content_block do
                  assert has_content? "nobel_prize.pdf"
                  assert has_content? "marathon_certificate.pdf"

                  edit_links = all("a[data-behavior=edit_record]", visible: false)
                  content_block_records = all(".dynamic-content-record-wrapper")

                  # Update title and attachment for first record
                  edit_links[0].execute_script("this.click()")
                  within(content_block_records[0]) do
                    fill_in "Title", with: "Accomplishment 1 Edited Title"
                    attach_file find("input[type='file']")[:id], "test/fixtures/files/gobierto_common/document-1.pdf"
                    find("a[data-behavior=add_record]").click
                  end

                  # Update title and attachment for second record
                  edit_links[1].execute_script("this.click()")
                  within(content_block_records[1]) do
                    fill_in "Title", with: "Accomplishment 2 Edited Title"
                    attach_file find("input[type='file']")[:id], "test/fixtures/files/gobierto_common/document-2.pdf"
                    find("a[data-behavior=add_record]").click
                  end
                end

                FileUploader::S3.any_instance.stubs(:call).returns("http://www.madrid.es/assets/documents/document-1.pdf", "http://www.madrid.es/assets/documents/document-2.pdf")

                click_button "Update"

                within accomplishments_content_block do
                  assert has_content? "Accomplishment 1 Edited Title"
                  assert has_content? "document-1.pdf"

                  assert has_content? "Accomplishment 2 Edited Title"
                  assert has_content? "document-2.pdf"
                end
              end
            end
          end
        end

        def test_content_block_record_remove_attachments
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                within accomplishments_content_block do
                  edit_links = all("a[data-behavior=edit_record]", visible: false)
                  content_block_records = all(".dynamic-content-record-wrapper")


                  row = all("td.content-block-record-value", text: "Ate 33 meatballs in 45 minutes").first
                  parent = row.find(:xpath, '..')
                  parent.find("a[data-behavior=edit_record]", visible: false).execute_script("this.click()")
                  table = parent.find(:xpath, '..')
                  sibling = table.all("tr").last
                  remove_atachment = sibling.first("input[data-behavior=remove_attachment]", visible: false).execute_script("this.click()")
                end

                click_button "Update"

                within accomplishments_content_block do
                  assert has_content? "Ate 33 meatballs in 45 minutes"
                  assert has_no_content? "meatballs_photo.png"
                end
              end
            end
          end
        end
      end
    end
  end
end
