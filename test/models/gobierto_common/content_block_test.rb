# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  class ContentBlockTest < ActiveSupport::TestCase
    def content_block
      @content_block ||= gobierto_common_content_blocks(:contact_methods)
    end

    def content_context
      @content_context ||= gobierto_people_people(:richard)
    end

    def test_valid
      assert content_block.valid?
    end

    def test_title
      assert_equal "Contact methods", content_block.title["en"]
      assert_equal "Formas de contacto", content_block.title["es"]
    end

    def test_localized_title
      assert_equal "Contact methods", content_block.localized_title
    end

    def test_records_without_content_context
      ContentBlock.content_context = nil

      expected_records = ContentBlockRecord.all.select do |content_block_record|
        content_block_record.content_block_id == content_block.id
      end.sort

      assert_equal expected_records.sort, content_block.records.sort
    end

    def test_records_with_content_context
      ContentBlock.content_context = content_context

      expected_records = content_context.content_block_records.select do |content_block_record|
        content_block_record.content_block_id == content_block.id
      end

      assert_equal expected_records.sort, content_block.records.sort
    end
  end
end
