# frozen_string_literal: true

class CollectionDecorator < BaseDecorator
  include Enumerable
  attr_reader :collection, :decorator

  def initialize(collection, decorator: nil)
    @collection = collection
    @decorator = decorator
  end

  def each(&block)
    @collection.each do |item|
      block.call(@decorator.try(:new, item) || item)
    end
  end
end
