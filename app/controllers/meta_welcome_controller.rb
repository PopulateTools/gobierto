class MetaWelcomeController < ApplicationController
  # TODO: this needs to be designed to work with different modules
  def index
    if Site.budgets_domain?(domain)
      render "gobierto_budgets/pages/home", layout: 'gobierto_budgets_application'
    else
      redirect_to gobierto_budgets_site_path
    end
  end
end
