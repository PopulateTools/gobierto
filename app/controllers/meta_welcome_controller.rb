class MetaWelcomeController < ApplicationController
  def index
    render_404 and return if current_site.nil?

    if current_site.configuration.home_page == "GobiertoPeople"
      redirect_to gobierto_people_root_path and return
    elsif current_site.configuration.home_page == "GobiertoBudgets"
      redirect_to gobierto_budgets_site_path and return
    elsif current_site.configuration.home_page == "GobiertoParticipation" ||
          current_site.configuration.home_page == "GobiertoIndicators"
      redirect_to eval("#{current_site.configuration.home_page.underscore}_root_path") and return
    end
  end
end
