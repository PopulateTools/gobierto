module GobiertoBudgetConsultations
  class ApplicationController < ::ApplicationController
    include User::SessionHelper

    layout "gobierto_budget_consultations/application"
  end
end
