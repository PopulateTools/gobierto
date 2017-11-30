# frozen_string_literal: true

class ListChildrenPages < Liquid::Tag
  def initialize(tag_name, params, tokens)
    super

    @page_slug = params.split("|").first.strip
    @level = params.split("|").last.split(":").last.strip.to_i
  end

  def render(context)
    current_site = context.environments.first["current_site"]
    page = current_site.pages.find_by_slug!(@page_slug)
    section_item = ::GobiertoCms::SectionItem.where(item_id: page.id)

    if section_item.any?
      return children_pages(section_item.first.children, @level)
    else
      return ""
    end
  rescue ActiveRecord::RecordNotFound
    return ""
  end

  def children_pages(nodes, level)
    html = []
    if nodes.any?
      html << "<div class='page_children'>"
      nodes.each do |node|
        html << "<div class='page_child'>"
        html << "<a href='" + node.item.to_url + "'>" + node.item.title + "</a>"
        level -= 1
        if node.children.any? && level != 0
          html << children_pages(node.children, level)
        end
        html << "</div>"
      end
      html << "</div>"
    end
    html.join.html_safe
  end
end

Liquid::Template.register_tag("list_children_pages", ListChildrenPages)
