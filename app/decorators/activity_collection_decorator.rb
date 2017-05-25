# frozen_string_literal: true

class ActivityCollectionDecorator < BaseDecorator
  attr_reader :collection, :total_pages

  def initialize(activities)
    @collection = activities

    @object = @collection.map { |activity| activity.subject.present? ? ActivityDecorator.new(activity) : nil }.compact
  end
end
