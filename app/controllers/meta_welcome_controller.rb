# frozen_string_literal: true

class MetaWelcomeController < ApplicationController
  include User::SessionHelper

  helper_method :cache_service

  def index
    render_404 and return if current_site.nil?

    if current_site.configuration.home_page != "GobiertoCms"
      render_404 and return
    else
      # This code allows the homepage to render a page without redirecting to the page url
      item = GlobalID::Locator.locate(current_site.configuration.home_page_item_id)
      render_404 and return if item.nil?

      if item.is_a?(GobiertoCms::Section)
        @section = item
        page = @section.first_item(only_public: true)
      else
        page = item
      end
      render_404 and return if page.nil?

      if @section ||= page.section
        @section_item = ::GobiertoCms::SectionItem.find_by!(item: page, section: @section)
      else
        @collection = page.collection
        @pages = current_site.pages.where(id: @collection.pages_in_collection).active.includes(:collection, :sections)
      end

      @page = GobiertoCms::PageDecorator.new(page)

      render "gobierto_cms/pages/meta_welcome", layout: "gobierto_cms/layouts/application"
    end
  end

  private

  def cache_service
    @cache_service ||= GobiertoCommon::CacheService.new(current_site, "GobiertoCms")
  end
end
