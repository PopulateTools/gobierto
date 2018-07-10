# frozen_string_literal: true

class PageUrl < Liquid::Tag
  def initialize(tag_name, page_slug, tokens)
    super
    @page_slug = page_slug.strip
  end

  def render(context)
    current_site = context.environments.first["current_site"]
    page = current_site.pages.find_by_slug!(@page_slug)
    return url_helpers.gobierto_cms_page_path(page.slug)
  rescue ActiveRecord::RecordNotFound
    return ""
  end

  private

  def url_helpers
    Rails.application.routes.url_helpers
  end
end

Liquid::Template.register_tag("page_url", PageUrl)
