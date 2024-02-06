# frozen_string_literal: true

module Liquid
  module GobiertoCms
    module Tags
      class ListItemsFrom < Liquid::Tag
        include ::GobiertoCms::PageHelper

        def initialize(tag_name, params, tokens)
          super

          @options = { date: true, intro_text: true, limit: 4, order: "DESC" }
          split_params = params.split("|")
          @collection_slug = split_params.first.strip

          if split_params.length > 1
            parsed_options = Hash[split_params.last.split(",").map{|e| e.split(":").map(&:strip) }].symbolize_keys
            parsed_options[:date] = parsed_options[:date] == "true" if parsed_options.has_key?(:date)
            parsed_options[:intro_text] = parsed_options[:intro_text] == "true" if parsed_options.has_key?(:intro_text)
            parsed_options[:limit] = parsed_options[:limit].to_i if parsed_options.has_key?(:limit)
            @options.merge!(parsed_options)
          end
        end

        def render(context)
          current_site = context.environments.first["current_site"]
          pages = fetch_pages(current_site)

          return "" if pages.empty?
          render_pages(pages)
        rescue ::ActiveRecord::RecordNotFound
          return ""
        end

        def render_pages(pages)
          html = [ %Q{<div class="list_items_from_collection">} ]
          pages.each do |page|
            page = ::GobiertoCms::PageDecorator.new(page)
            collection_item_text = [ %Q{<div class="collection_item">} ]
            if page.main_image
              collection_item_text << %Q{ <img src="#{page.main_image}"> }
            end
            if @options[:date]
              collection_item_text << %Q{ <span class="date">#{::I18n.l(page.published_on, format: "%d %b %y")}</span> }
            end
            collection_item_text << %Q{ <h2>#{page.title}</h2> }
            if @options[:intro_text]
              collection_item_text << %Q{ <p class="description">#{page.summary}</p> }
            end
            collection_item_text << "</div>"
            html << helpers.link_to(collection_item_text.join.html_safe, gobierto_cms_page_or_news_path(page))
          end
          html << "</div>"
          html.join.html_safe
        end

        private

        def fetch_pages(current_site)
          collection = current_site.collections.find_by!(slug: @collection_slug)
          current_site.pages.where(id: collection.pages_in_collection).active.limit(@options[:limit]).order("published_on #{@options[:order]}")
        end

        def helpers
          ::ActionController::Base.helpers
        end
      end
    end
  end
end

Liquid::Template.register_tag("list_items_from", Liquid::GobiertoCms::Tags::ListItemsFrom)
