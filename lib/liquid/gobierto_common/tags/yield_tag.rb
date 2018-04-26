class YieldTag < ::Liquid::Tag
  Syntax = /(#{::Liquid::QuotedFragment}+)/

  include ActionView::Helpers::SanitizeHelper

  def initialize(tag_name, markup, context)
    super

    if markup =~ Syntax
      @identifier = $1.gsub('\'', '').to_sym
    else
      raise SyntaxError.new("Syntax Error - Valid syntax: {% yield [name] %}")
    end
  end

  def render(context)
    @context = context

    sanitize(@context.registers[:view].content_for(@identifier))
  end
end

Liquid::Template.register_tag('yield', YieldTag)
