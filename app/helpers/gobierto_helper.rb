module GobiertoHelper

  def pending(&block)
    yield if controller_name == 'sandbox'
  end

  def todo_link_to(&block)
    anchor_text = yield
    "#{anchor_text} 🛠".html_safe
  end

  def markdown(text)
    return if text.blank?

    options = {
      filter_html:     false,
      hard_wrap:       true,
      link_attributes: { rel: 'nofollow', target: "_blank" },
      space_after_headers: true,
      fenced_code_blocks: true
    }

    extensions = {
      autolink:           true,
      superscript:        true,
      disable_indented_code_blocks: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    sanitize markdown.render(text)
  end

  def algolia_search_client
    @algolia_search_client ||= GobiertoCommon::Search.new(current_site)
  end

  private

    def error_messages_for(entity)
      return '' if entity.nil? || entity.errors.empty?

      if entity.errors.any?
        content_tag :ul do
          entity.errors.full_messages.map do |msg|
            content_tag :li do
              msg
            end
          end.join("\n").html_safe
        end
      end
    end

end
