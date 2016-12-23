module GobiertoBudgetConsultations
  class ApplicationController < ::ApplicationController
    include User::SessionHelper
    include User::VerificationHelper

    layout "gobierto_budget_consultations/layouts/application"
  end
end
