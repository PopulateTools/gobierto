# frozen_string_literal: true

class MetaWelcomeController < ApplicationController
  def index
    render_404 and return if current_site.nil?

    unless current_site.configuration.home_page == "GobiertoCms"
      redirect_to eval("#{current_site.configuration.home_page.underscore}_root_path") and return
    else
      item = GlobalID::Locator.locate(current_site.configuration.home_page_item_id)
      redirect_to item.to_url and return
    end
  end
end
