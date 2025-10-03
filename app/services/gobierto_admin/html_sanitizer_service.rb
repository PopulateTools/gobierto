# frozen_string_literal: true

module GobiertoAdmin
  class HtmlSanitizerService
    SAFELIST_TAGS = %w(
      div span p h1 h2 h3 h4 h5 h6
      a img br hr
      ul ol li
      strong b em i u
      table thead tbody tr td th
      blockquote pre code
      style
    )

    SAFELIST_ATTRIBUTES = %w(
      class id style
      href src alt title
      width height
      target rel
      data-* aria-*
    )

    def self.sanitize(html_content)
      return "" if html_content.blank?

      sanitizer = Rails::Html::SafeListSanitizer.new(prune: true)
      sanitizer.sanitize(
        html_content,
        tags: SAFELIST_TAGS,
        attributes: SAFELIST_ATTRIBUTES
      )
    end
  end
end
