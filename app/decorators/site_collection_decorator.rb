# frozen_string_literal: true

class SiteCollectionDecorator < BaseDecorator
  attr_reader :collection

  def initialize(sites)
    @collection = sites

    @object = @collection.map { |site| SiteDecorator.new(site) }
  end
end
