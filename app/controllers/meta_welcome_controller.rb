class MetaWelcomeController < ApplicationController
  # TODO: this needs to work with different modules
  def index
    redirect_to gobierto_budgets_site_path
  end
end
