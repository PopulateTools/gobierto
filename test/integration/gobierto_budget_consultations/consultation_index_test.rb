# frozen_string_literal: true

require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_budget_consultations_consultations_path
    end

    def active_consultations
      @active_consultations ||= begin
        [
          gobierto_budget_consultations_consultations(:madrid_open),
          gobierto_budget_consultations_consultations(:madrid_open_attached)
        ]
      end
    end

    def past_consultations
      @past_consultations ||= begin
        [gobierto_budget_consultations_consultations(:madrid_past)]
      end
    end

    def site
      @site ||= sites(:madrid)
    end

    def user
      @user ||= users(:dennis)
    end

    def test_consultation_index
      with_current_site(site) do
        visit @path

        assert has_selector?("h2", text: "Active consultations")

        within ".active-consultations" do
          active_consultations.each do |consultation|
            assert has_link?(consultation.title)
          end
        end

        assert has_selector?("h2", text: "Previous consultations")

        within ".past-consultations" do
          past_consultations.each do |consultation|
            assert has_link?(consultation.title)
          end
        end
      end
    end

    def test_consultation_index_with_single_active_consultation
      with_current_site(site) do
        remaining_consultation = active_consultations.first

        Consultation.where.not(id: remaining_consultation.id).delete_all
        assert_equal 1, Consultation.active.count

        visit @path

        assert has_content?("Do you want to opinate?")
      end
    end

    def test_see_participated_consultations
      with_signed_in_user(user) do
        visit @path

        assert has_selector?("h2", text: "Active consultations")

        within ".active-consultations" do
          assert has_link?("Consulta sobre los presupuestos de Madrid (You already responded)")
          assert has_link?("Consulta adjunta sobre los presupuestos de Madrid")
        end
      end
    end
  end
end
