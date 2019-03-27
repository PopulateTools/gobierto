# frozen_string_literal: true

class YieldTag < ::Liquid::Tag
  Syntax = /(#{::Liquid::QuotedFragment}+)/

  def initialize(tag_name, markup, context)
    super

    if markup =~ Syntax
      @identifier = $1.gsub("'", "").to_sym
    else
      raise SyntaxError.new("Syntax Error - Valid syntax: {% yield [name] %}")
    end
  end

  def render(context)
    @context = context

    @context.registers[:view].content_for(@identifier).try(:html_safe)
  end
end

Liquid::Template.register_tag("yield", YieldTag)
