require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationResponseCreateTest < ActionDispatch::IntegrationTest
    include ActionView::Helpers::NumberHelper

    def setup
      super
      @path = gobierto_budget_consultations_consultation_new_response_path(consultation)
      @closed_path = gobierto_budget_consultations_consultation_new_response_path(closed_consultation)
    end

    def consultation
      @consultation ||= gobierto_budget_consultations_consultations(:madrid_open)
    end

    def closed_consultation
      @closed_consultation ||= gobierto_budget_consultations_consultations(:madrid_past)
    end

    def site
      @site ||= consultation.site
    end

    def user
      @user ||= users(:dennis)
    end

    def unverified_user
      @unverified_user ||= users(:susan)
    end

    def test_consultation_response_creation_when_not_signed_in
      with_current_site(site) do
        visit @path

        assert has_content?("We need you to sign in to continue.")
      end
    end

    def test_consultation_response_creation_when_user_is_not_verified
      with_current_site(site) do
        with_signed_in_user(unverified_user) do
          visit @path

          assert has_content?("We need to verify your identity to continue")
        end
      end
    end

    def test_consultation_response_creation_when_consultation_is_closed
      with_current_site(site) do
        with_signed_in_user(user) do
          visit @closed_path

          assert has_content?("This consultation doesn't allow participations.")
        end
      end
    end

    def test_consultation_response_creation_workflow
      with_current_site(site) do
        with_signed_in_user(user) do
          visit @path

          consultation.consultation_items.each_with_index do |consultation_item, consultation_item_index|
            within ".consultation_item_#{consultation_item_index}" do
              consultation_item.response_options.each do |response_option|
                assert has_selector?(".response-option.#{response_option.label}")
              end

              choose I18n.t("gobierto_budget_consultations.consultation_items.options.keep")
            end
          end

          click_button "Enviar"

          within "table.budget-line_list" do
            consultation.consultation_items.each do |consultation_item|
              assert has_selector?("td.budget-line_title", text: consultation_item.title)
              assert has_selector?(
                ".button_marker.active",
                text: I18n.t("gobierto_budget_consultations.consultation_items.options.short.keep")
              )
            end

            assert has_selector?(
              ".consultation_marker.consultation_budget_amount .qty",
              text: number_to_currency(consultation.budget_amount)
            )

            assert has_selector?(
              ".consultation_marker.consultation_response_budget_amount .qty",
              text: number_to_currency(consultation.consultation_items.map(&:budget_line_amount).sum)
            )
          end

          click_link "Revisar"

          assert has_selector?("form#edit_consultation_response")

          click_button "Enviar"

          assert has_selector?("table.budget-line_list")

          click_button "Confirmar"

          within ".consultation_thanks" do
            assert has_content?("Estupendo, muchas gracias por tu aportación")
          end
        end
      end
    end
  end
end
