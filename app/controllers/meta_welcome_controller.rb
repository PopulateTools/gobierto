# frozen_string_literal: true

class MetaWelcomeController < ApplicationController
  def index
    render_404 and return if current_site.nil?

    redirect_to eval("#{current_site.configuration.home_page.underscore}_root_path") and return
  end
end
