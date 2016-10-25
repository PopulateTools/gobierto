class MetaWelcomeController < ApplicationController
  def index
    if Site.budgets_domain?(domain)
      render "gobierto_budgets/pages/home", layout: 'gobierto_budgets_application'
    else
      redirect_to gobierto_sites_site_path
    end
  end
end
