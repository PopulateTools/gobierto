module GobiertoHelper

  def pending(&block)
    yield if controller_name == 'sandbox'
  end

  def flush_the_flash(entity = nil)
    if flash[:notice]
      css_class = 'notice success'
      msg = flash[:notice]
      icon_class = 'fa-check-circle-o'
    elsif flash[:alert]
      css_class = 'notice error'
      msg = flash[:alert]
      icon_class = 'fa-times'
    else
      return
    end

    content_tag :div, class: css_class do
      content_tag(:p, content_tag(:i, '', class: 'fa ' + icon_class) + ' ' + msg) + error_messages_for(entity)
    end
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

    markdown.render(text).html_safe

    def twitter_share(message, url)
      short_url_length = 24
      total_message_length = 140
      signature = "En @gobierto: "
      max_message_length = total_message_length - short_url_length - signature.length

      to_share = signature
      to_share += (message.length > max_message_length) ? message.slice(0, max_message_length - 3) + "..." : message
      to_share += " "+url
      to_share
    end
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
