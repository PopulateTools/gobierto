# frozen_string_literal: true

require "test_helper"
require "support/extensions/gobierto_common/trackable_test"

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationFormTest < ActiveSupport::TestCase
      include ::GobiertoCommon::TrackableTest

      def subject_class
        ConsultationForm
      end

      def valid_consultation_form
        @valid_consultation_form ||= ConsultationForm.new(
          admin_id: admin.id,
          site_id: site.id,
          title: consultation.title,
          description: consultation.description,
          opens_on: consultation.opens_on,
          closes_on: consultation.closes_on,
          visibility_level: consultation.visibility_level
        )
      end
      alias trackable valid_consultation_form

      def valid_consultation_with_opening_date_range_form
        @valid_consultation_with_opening_date_range_form ||= ConsultationForm.new(
          admin_id: admin.id,
          site_id: site.id,
          title: consultation.title,
          description: consultation.description,
          opening_date_range: "2016-01-01 - 2016-12-01"
        )
      end

      def invalid_consultation_form
        @invalid_consultation_form ||= ConsultationForm.new(
          admin_id: admin.id,
          site_id: site.id,
          title: nil,
          description: nil,
          opens_on: nil,
          closes_on: nil
        )
      end

      def consultation
        @consultation ||= gobierto_budget_consultations_consultations(:madrid_open)
      end

      def admin
        @admin ||= gobierto_admin_admins(:tony)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_save_with_valid_attributes
        assert valid_consultation_form.save
      end

      def test_save_with_valid_attributes_for_opening_date_range_form
        assert valid_consultation_with_opening_date_range_form.save
      end

      def test_error_messages_with_invalid_attributes
        invalid_consultation_form.save

        assert_equal 1, invalid_consultation_form.errors.messages[:title].size
        assert_equal 1, invalid_consultation_form.errors.messages[:opening_date_range].size
      end

      def test_opening_date_range
        assert_equal(
          "#{valid_consultation_form.opens_on} - #{valid_consultation_form.closes_on}",
          valid_consultation_form.opening_date_range
        )
      end

      def test_opening_date_range_for_opening_date_range_form
        assert_equal(
          "2016-01-01",
          valid_consultation_with_opening_date_range_form.opens_on
        )

        assert_equal(
          "2016-12-01",
          valid_consultation_with_opening_date_range_form.closes_on
        )
      end
    end
  end
end
