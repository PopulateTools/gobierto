# frozen_string_literal: true

class ListChildrenPages < Liquid::Tag
  def initialize(tag_name, params, tokens)
    super

    @page_slug = params.split("|").first.strip
    @level = if params.include?("level")
               params.split("|").last.split(":").last.strip.to_i
             else
               1
             end
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
    if level.positive?
      if nodes.any?
        html << "<div class='page_children'>"
        nodes.each do |node|
          html << "<div class='page_child'>"
          html << "<a href='" + node.item.to_path + "'>" + node.item.title + "</a>"
          if node.children.any? && level.positive?
            html << children_pages(node.children, level - 1)
          end
          html << "</div>"
        end
        html << "</div>"
      end
    end
    html.join.html_safe
  end
end

Liquid::Template.register_tag("list_children_pages", ListChildrenPages)
