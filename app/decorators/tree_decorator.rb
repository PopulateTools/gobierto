# frozen_string_literal: true

class TreeDecorator
  include Enumerable
  attr_reader :tree, :decorator

  delegate :exists?, :empty?, to: :tree
  delegate :decorated_values?, to: :decorator

  def initialize(tree, decorator: nil, options: {})
    @tree = tree
    @decorator = decorator
    @opts = options
  end

  def each
    @tree.each do |key, value|
      if @opts.blank?
        yield(@decorator.try(:new, key) || key, TreeDecorator.new(value, decorator: decorator))
      else
        yield(@decorator.try(:new, key, @opts) || key, TreeDecorator.new(value, decorator: decorator, options: @opts))
      end
    end
  end
end
