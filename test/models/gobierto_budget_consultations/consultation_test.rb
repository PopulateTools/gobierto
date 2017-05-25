# frozen_string_literal: true

require 'test_helper'
require 'support/concerns/user/subscribable_test'

module GobiertoBudgetConsultations
  class ConsultationTest < ActiveSupport::TestCase
    include User::SubscribableTest

    def consultation
      @consultation ||= gobierto_budget_consultations_consultations(:madrid_open)
    end
    alias subscribable consultation

    def past_consultation
      @past_consultation ||= gobierto_budget_consultations_consultations(:madrid_past)
    end

    def upcoming_consultation
      @upcoming_consultation ||= gobierto_budget_consultations_consultations(:madrid_upcoming)
    end

    def test_valid
      assert consultation.valid?
    end

    def test_active_scope
      subject = Consultation.active

      assert_includes subject, consultation
      refute_includes subject, past_consultation
    end

    def test_active_scope_on_drafts
      consultation.draft!
      subject = Consultation.active

      refute_includes subject, consultation
    end

    def test_past_scope
      subject = Consultation.past

      assert_includes subject, past_consultation
      refute_includes subject, consultation
    end

    def test_past_scope_on_drafts
      past_consultation.draft!
      subject = Consultation.past

      refute_includes subject, past_consultation
    end

    def test_upcoming_scope
      consultation.update_columns(opens_on: Date.tomorrow)
      subject = Consultation.upcoming

      assert_includes subject, consultation
      refute_includes subject, past_consultation
    end

    def test_opening_today_scope
      consultation.update_columns(opens_on: Date.today)
      subject = Consultation.opening_today

      assert_includes subject, consultation
      refute_includes subject, past_consultation
    end

    def test_closing_today_scope
      consultation.update_columns(closes_on: Date.today)
      subject = Consultation.closing_today

      assert_includes subject, consultation
      refute_includes subject, past_consultation
    end

    def test_about_to_close_scope
      consultation.update_columns(closes_on: 2.days.from_now.to_date)
      subject = Consultation.about_to_close

      assert_includes subject, consultation
      refute_includes subject, past_consultation
    end

    def test_open?
      assert consultation.open?
      refute past_consultation.open?
      refute upcoming_consultation.open?
    end

    def test_past?
      assert past_consultation.past?
      refute consultation.past?
      refute upcoming_consultation.past?
    end

    def test_upcoming?
      assert upcoming_consultation.upcoming?
      refute past_consultation.upcoming?
      refute consultation.upcoming?
    end

    def test_open_in_range
      consultation.visibility_level = 'active'
      consultation.opens_on = Date.today
      consultation.closes_on = Date.tomorrow

      assert consultation.open?
    end

    def test_open_out_of_range
      consultation.visibility_level = 'active'
      consultation.opens_on = Date.tomorrow
      consultation.closes_on = Date.tomorrow

      refute consultation.open?
    end

    def test_open_with_draft_visibility_level
      consultation.visibility_level = 'draft'
      consultation.opens_on = Date.today
      consultation.closes_on = Date.tomorrow

      refute consultation.open?
    end

    def test_calculate_budget_amount
      consultation.budget_amount = 0.0
      assert_equal 0.0, consultation.budget_amount

      consultation_items_total_amount = consultation.consultation_items.sum(:budget_line_amount)

      assert_difference 'consultation.budget_amount', consultation_items_total_amount do
        consultation.calculate_budget_amount
      end
    end
  end
end
