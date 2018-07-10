module GobiertoBudgetConsultations
  class ApplicationController < ::ApplicationController
    include User::SessionHelper
    include User::VerificationHelper

    layout "gobierto_budget_consultations/layouts/application"

    before_action { module_enabled!(current_site, "GobiertoBudgetConsultations") }

    def set_current_site
      @site = SiteDecorator.new(current_site)
    end
    protected

    def check_not_responded
      if @consultation && user_signed_in? && @consultation.already_responded?(current_user)
        flash[:alert] = t('gobierto_budget_consultations.layouts.errors.already_responded')
        redirect_to gobierto_budget_consultations_consultation_show_confirmation_path(@consultation) and return false
      end
    end

    def raise_consultation_closed
      redirect_to(
        request.referrer || user_root_path,
        alert: "This consultation doesn't allow participations."
      )
    end
  end
end
