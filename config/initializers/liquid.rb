# frozen_string_literal: true

Liquid::Template.error_mode = :lax

require "liquid/gobierto_cms/tags/page_url"
require "liquid/gobierto_cms/tags/page_title"
require "liquid/gobierto_cms/tags/list_children_pages"
require "liquid/gobierto_common/filters/image_filter"
require "liquid/gobierto_common/filters/liquid_i18n"
require "liquid/gobierto_common/tags/render_partial"
