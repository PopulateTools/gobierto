# frozen_string_literal: true

module Integration
  module DynamicContentHelpers
    def content_blocks
      @content_blocks ||= content_context.content_blocks(site.id)
    end

    def fill_in_content_blocks
      content_blocks.each do |content_block|
        within "#content-block-#{content_block.id}" do
          if content_block.records.any?
            content_block.records.each do |content_block_record|
              within ".dynamic-content-record-wrapper.content-block-record-#{content_block_record.id}" do
                with_hidden_elements do
                  find("a[data-behavior=edit_record]").click
                end

                content_block.fields.each do |content_block_field|
                  within ".content-block-field-#{content_block_field.name.parameterize}" do
                    if content_block_field.currency?
                      fill_in content_block_field.label[I18n.locale], with: "420,000.00"
                    else
                      fill_in content_block_field.label[I18n.locale], with: "Value for #{content_block_field.name}"
                    end
                  end
                end

                find("a[data-behavior=add_record]").click
              end
            end
          else
            find("a[data-behavior=add_child]").click

            within ".cloned-dynamic-content-record-wrapper", match: :first do
              content_block.fields.each do |content_block_field|
                within ".content-block-field-#{content_block_field.name.parameterize}" do
                  if content_block_field.currency?
                    fill_in content_block_field.label[I18n.locale], with: "420,000.00"
                  else
                    fill_in content_block_field.label[I18n.locale], with: "Value for #{content_block_field.name}"
                  end
                end
              end

              find("a[data-behavior=add_record]").click
            end
          end
        end
      end
    end

    def assert_content_blocks_have_the_right_values
      content_blocks.each do |content_block|
        within "#content-block-#{content_block.id} .dynamic-content-record-view", match: :first do
          content_block.fields.each do |content_block_field|
            if content_block_field.currency?
              assert has_selector?(".content-block-record-value", text: "420,000.00")
            else
              assert has_selector?(".content-block-record-value", text: "Value for #{content_block_field.name}")
            end
          end
        end
      end
    end

    def assert_content_blocks_can_be_managed
      assert_content_record_can_be_added
      assert_content_record_can_be_edited
      assert_content_record_changes_can_be_canceled
      assert_content_record_can_be_deleted
    end

    private

    def assert_content_record_can_be_added
      content_block = content_blocks.first

      within "#content-block-#{content_block.id}" do
        find("a[data-behavior=add_child]").click

        within ".cloned-dynamic-content-record-wrapper" do
          content_block.fields.each do |content_block_field|
            within ".content-block-field-#{content_block_field.name.parameterize}" do
              if content_block_field.currency?
                fill_in content_block_field.label[I18n.locale], with: "430,000.00"
              else
                fill_in content_block_field.label[I18n.locale], with: "Added value for #{content_block_field.name}"
              end
            end
          end

          find("a[data-behavior=add_record]").click

          content_block.fields.each do |content_block_field|
            if content_block_field.currency?
              assert has_selector?(".content-block-record-value", text: "430,000.00")
            else
              assert has_selector?(".content-block-record-value", text: "Added value for #{content_block_field.name}")
            end
          end
        end
      end
    end

    def assert_content_record_can_be_edited
      content_block = content_blocks.first
      content_block_record = content_block.records.sorted.last

      within "#content-block-#{content_block.id}" do
        within ".dynamic-content-record-wrapper.content-block-record-#{content_block_record.id}" do
          with_hidden_elements do
            find("a[data-behavior=edit_record]").click
          end

          content_block.fields.each do |content_block_field|
            within ".content-block-field-#{content_block_field.name.parameterize}" do
              if content_block_field.currency?
                fill_in content_block_field.label[I18n.locale], with: "440,000.00"
              else
                fill_in content_block_field.label[I18n.locale], with: "Updated value for #{content_block_field.name}"
              end
            end
          end

          find("a[data-behavior=add_record]").click

          content_block.fields.each do |content_block_field|
            if content_block_field.currency?
              assert has_selector?(".content-block-record-value", text: "440,000.00")
            else
              assert has_selector?(".content-block-record-value", text: "Updated value for #{content_block_field.name}")
            end
          end
        end
      end
    end

    def assert_content_record_changes_can_be_canceled
      content_block = content_blocks.first
      content_block_record = content_block.records.sorted.last

      within "#content-block-#{content_block.id}" do
        within ".dynamic-content-record-wrapper.content-block-record-#{content_block_record.id}" do
          with_hidden_elements do
            find("a[data-behavior=edit_record]").click
          end

          content_block.fields.each do |content_block_field|
            within ".content-block-field-#{content_block_field.name.parameterize}" do
              if content_block_field.currency?
                fill_in content_block_field.label[I18n.locale], with: "450,000.00"
              else
                fill_in content_block_field.label[I18n.locale], with: "Discarded value for #{content_block_field.name}"
              end
            end
          end

          find("a[data-behavior=cancel_record]").click

          content_block.fields.each do |content_block_field|
            if content_block_field.currency?
              assert has_selector?(".content-block-record-value", text: "440,000.00")
            else
              assert has_selector?(".content-block-record-value", text: "Updated value for #{content_block_field.name}")
            end
          end
        end
      end
    end

    def assert_content_record_can_be_deleted
      content_block = content_blocks.first
      content_block_record = content_block.records.sorted.last

      within "#content-block-#{content_block.id}" do
        within ".dynamic-content-record-wrapper.content-block-record-#{content_block_record.id}" do
          with_hidden_elements do
            find("a[data-behavior=delete_record]").click
          end
        end

        assert has_no_selector?(".dynamic-content-record-wrapper.content-block-record-#{content_block_record.id}")
      end
    end
  end
end
