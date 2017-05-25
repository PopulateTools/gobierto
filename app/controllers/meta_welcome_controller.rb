# frozen_string_literal: true

class MetaWelcomeController < ApplicationController
  def index
    render_404 && return if current_site.nil?

    if current_site.configuration.modules.include?('GobiertoPeople')
      redirect_to(gobierto_people_root_path) && return
    elsif current_site.configuration.modules.include?('GobiertoBudgets')
      redirect_to(gobierto_budgets_site_path) && return
    else
      redirect_to(eval("#{current_site.configuration.modules.first.underscore}_root_path")) && return
    end
  end
end
