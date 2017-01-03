module Integration
  module DynamicContentHelpers
    def content_blocks
      @content_blocks ||= content_context.content_blocks(site.id)
    end

    def fill_in_content_blocks
      content_blocks.each do |content_block|
        within "#content-block-#{content_block.id}" do
          if content_context.content_block_records.any?
            content_block.records.each do |content_block_record|
              within ".dynamic-content-record-wrapper.content-block-record-#{content_block_record.id}" do
                content_block.fields.each do |content_block_field|
                  within ".content-block-field-#{content_block_field.name.parameterize}" do
                    fill_in content_block_field.label[I18n.locale], with: "Value for #{content_block_field.name}"
                  end
                end
              end
            end
          else
            within ".dynamic-content-record-wrapper.content-block-record-new" do
              content_block.fields.each do |content_block_field|
                within ".content-block-field-#{content_block_field.name.parameterize}" do
                  fill_in content_block_field.label[I18n.locale], with: "Value for #{content_block_field.name}"
                end
              end
            end
          end
        end
      end
    end

    def assert_content_blocks_have_the_right_values
      content_blocks.each do |content_block|
        within "#content-block-#{content_block.id}" do
          content_block.fields.each do |content_block_field|
            within ".content-block-field-#{content_block_field.name.parameterize}" do
              assert has_field?(content_block_field.label[I18n.locale], with: "Value for #{content_block_field.name}")
            end
          end
        end
      end
    end
  end
end
