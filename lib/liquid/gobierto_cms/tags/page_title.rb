# frozen_string_literal: true

class PageTitle < Liquid::Tag
  def initialize(tag_name, page_slug, tokens)
    super
    @page_slug = page_slug.strip
  end

  def render(context)
    current_site = context.environments.first["current_site"]
    page = current_site.pages.find_by_slug!(@page_slug)
    return page.title
  rescue ActiveRecord::RecordNotFound
    return ""
  end
end

Liquid::Template.register_tag("page_title", PageTitle)
