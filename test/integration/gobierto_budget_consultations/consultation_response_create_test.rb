require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationResponseCreateTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = budget_consultation_new_response_path(consultation)
      @closed_path = budget_consultation_new_response_path(closed_consultation)
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

          assert has_content?("Your account is not yet verified.")
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

    def test_consultation_response_creation
      with_current_site(site) do
        with_signed_in_user(user) do
          visit @path

          consultation.consultation_items.each_with_index do |consultation_item, consultation_item_index|
            within ".consultation_item_#{consultation_item_index}" do
              consultation_item.response_options.each do |response_option|
                assert has_selector?(".response-option.#{response_option.label}")
              end

              choose I18n.t("gobierto_budget_consultations.consultation_items.options.#{consultation_item.response_options.first.label}")
            end
          end

          click_button "Enviar"

          within "table.budget-line_list" do
            consultation.consultation_items.each do |consultation_item|
              assert has_selector?("td.budget-line_title", text: consultation_item.title)
              assert has_selector?(
                ".button_marker.active",
                text: I18n.t("gobierto_budget_consultations.consultation_items.options.short.#{consultation_item.response_options.first.label}")
              )
            end
          end
        end
      end
    end
  end
end
