require "test_helper"

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationResponseFormTest < ActiveSupport::TestCase
      def valid_consultation_response_form
        @valid_consultation_response_form ||= ConsultationResponseForm.new(
          document_number_digest: document_number_digest,
          consultation_id: consultation.id,
          selected_options: Hash[consultation_items.map do |item|
            [item.id.to_s, nil]
          end],
          date_of_birth_year: 1992,
          date_of_birth_month: 1,
          date_of_birth_day: 1,
          gender: "male",
          custom_records: {
            madrid_custom_user_field_district.name => { "custom_user_field_id" => madrid_custom_user_field_district.id, "value" => madrid_custom_user_field_district.options.keys.first },
            madrid_custom_user_field_association.name => { "custom_user_field_id" => madrid_custom_user_field_association.id, "value" => "Foo" }
          }
        )
      end

      def invalid_consultation_response_form
        @invalid_consultation_response_form ||= ConsultationResponseForm.new(
          document_number_digest: nil,
          consultation_id: nil,
          selected_options: {}
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

      def document_number_digest
        @document_number_digest ||= SecretAttribute.digest("00000000D")
      end

      def consultation_items
        @consultation_items ||= consultation.consultation_items
      end

      def madrid_custom_user_field_district
        @madrid_custom_user_field_district ||= gobierto_common_custom_user_fields(:madrid_custom_user_field_district)
      end

      def madrid_custom_user_field_association
        @madrid_custom_user_field_association ||= gobierto_common_custom_user_fields(:madrid_custom_user_field_association)
      end

      def test_valid_with_valid_attributes
        assert valid_consultation_response_form.save
      end

      def test_user_information
        valid_consultation_response_form.save

        user_information = valid_consultation_response_form.consultation_response.user_information
        assert_equal "male", user_information["gender"]
        assert_equal "1992-01-01", user_information["date_of_birth"]
        assert_equal user_information["district"], {"raw_value"=>"randomstring1", "localized_value"=>"Center"}
        assert_equal user_information["association"], {"raw_value"=>"Foo", "localized_value"=>"Foo"}
      end

      def test_error_messages_with_invalid_attributes
        refute invalid_consultation_response_form.save

        assert_equal 1, invalid_consultation_response_form.errors.messages[:document_number_digest].size
        assert_equal 1, invalid_consultation_response_form.errors.messages[:census_item].size
        assert_equal 1, invalid_consultation_response_form.errors.messages[:consultation].size
        assert_equal 1, invalid_consultation_response_form.errors.messages[:site].size
        assert_equal 1, invalid_consultation_response_form.errors.messages[:selected_options].size
      end
    end
  end
end
