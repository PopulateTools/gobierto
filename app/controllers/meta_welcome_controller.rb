# frozen_string_literal: true

class MetaWelcomeController < ApplicationController
  include User::SessionHelper

  def index
    render_404 and return if current_site.nil?

    if current_site.configuration.home_page != "GobiertoCms"
      redirect_to eval("#{current_site.configuration.home_page.underscore}_root_path")
    else
      # This code allows the homepage to render a page without redirecting to the page url
      item = GlobalID::Locator.locate(current_site.configuration.home_page_item_id)
      render_404 and return if item.nil?

      if item.is_a?(GobiertoCms::Section)
        @section = item
        @page = @section.first_item
      else
        @page = item
      end

      if @section ||= @page.section
        @section_item = ::GobiertoCms::SectionItem.find_by!(item: @page, section: @section)
      else
        @collection = @page.collection
        @pages = ::GobiertoCms::Page.where(id: @collection.pages_in_collection).active
      end

      render "gobierto_cms/pages/show"
    end
  end
end
