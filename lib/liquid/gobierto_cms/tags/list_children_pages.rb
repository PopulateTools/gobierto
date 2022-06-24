# frozen_string_literal: true

module Liquid
  module GobiertoCms
    module Tags
      class ListChildrenPages < Liquid::Tag
        include ::GobiertoCms::PageHelper

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
            return children_pages(section_item.first.children.not_archived.not_drafted, @level)
          else
            return ""
          end
        rescue ::ActiveRecord::RecordNotFound
          return ""
        end

        def children_pages(nodes, level)
          html = []
          if level.positive?
            if nodes.any?
              html << "<div class='page_children'>"
              nodes.each do |node|
                next if node.item.collection.blank?

                html << "<div class='page_child'>"
                html << ::ActionController::Base.helpers.link_to(node.item.title,
                                                                gobierto_cms_page_or_news_path(node.item))
                if node.children.any?
                  html << children_pages(node.children.not_archived.not_drafted, level - 1)
                end
                html << "</div>"
              end
              html << "</div>"
            end
          end
          html.join.html_safe
        end
      end
    end
  end
end

Liquid::Template.register_tag("list_children_pages", Liquid::GobiertoCms::Tags::ListChildrenPages)
