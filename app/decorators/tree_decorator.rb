# frozen_string_literal: true

class TreeDecorator
  include Enumerable
  attr_reader :tree, :decorator

  delegate :exists?, :empty?, to: :tree
  delegate :decorated_values?, to: :decorator

  def initialize(tree, decorator: nil, opts: {})
    @tree = tree
    @decorator = decorator
    @opts = opts
  end

  def each
    @tree.each do |key, value|
      if @opts.blank?
        yield(@decorator.try(:new, key) || key, TreeDecorator.new(value, decorator: decorator))
      else
        yield(@decorator.try(:new, item, opts: @opts) || item, TreeDecorator.new(value, decorator: decorator, opts: @opts))
      end
    end
  end
end
