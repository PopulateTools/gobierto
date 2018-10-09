# frozen_string_literal: true

class CollectionDecorator < BaseDecorator
  include Enumerable
  attr_reader :collection, :decorator

  delegate :exists?, :empty?, to: :collection

  def initialize(collection, decorator: nil, opts: {})
    @collection = collection
    @decorator = decorator
    @opts = opts
  end

  def each
    @collection.each do |item|
      if @opts.blank?
        yield(@decorator.try(:new, item) || item)
      else
        yield(@decorator.try(:new, item, opts: @opts) || item)
      end
    end
  end
end
