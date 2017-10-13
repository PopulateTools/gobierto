# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  module GobiertoParticipation
    class ProcessFormTest < ActiveSupport::TestCase

      def valid_process_form
        @valid_process_form ||= ProcessForm.new(
          site_id: site.id,
          title_translations: { I18n.locale => process.title },
          body_translations:  { I18n.locale => process.body },
          slug: "#{process.slug}-2",
          process_type: process.process_type,
          starts: process.starts,
          ends: process.ends,
          stages_attributes: { '0' => process_stage }
        )
      end

      def invalid_process_form
        @invalid_process_form ||= ProcessForm.new(
          site_id: site,
          title_translations: nil,
          body_translations: nil,
          slug: nil,
          process_type: process.process_type,
          starts: nil,
          ends: nil
        )
      end

      def process
        @process ||= gobierto_participation_processes(:local_budgets_process)
      end

      def process_stage
        @process_stage ||= begin
          stage = gobierto_participation_process_stages(:local_budgets_information_stage)
          stage.process = process
          stage
        end
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_save_process_with_valid_attributes
        assert valid_process_form.save
      end

      def test_process_error_messages_with_invalid_attributes_wadus
        invalid_process_form.save

        assert_equal 1, invalid_process_form.errors.messages[:title_translations].size
        assert_equal 0, invalid_process_form.errors.messages[:body_translations].size
        assert_equal 0, invalid_process_form.errors.messages[:slug].size
      end

    end
  end
end
