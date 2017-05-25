# frozen_string_literal: true

require 'test_helper'

module GobiertoCommon
  class ContentBlockRecordTest < ActiveSupport::TestCase
    def content_block_record
      @content_block_record ||= gobierto_common_content_block_records(:contact_method_twitter)
    end

    def test_valid
      assert content_block_record.valid?
    end

    def test_fields
      content_block_record.fields.each do |content_block_record_field|
        assert_kind_of ContentBlockRecordField, content_block_record_field
      end
    end

    def test_fields_setter
      field_instances = [
        ContentBlockRecordField.new(
          name: 'Foo',
          value: 'Bar'
        )
      ]

      content_block_record.fields = field_instances

      assert_equal(field_instances, content_block_record.fields)
      assert_equal({ 'Foo' => 'Bar' }, content_block_record.payload)
    end
  end
end
