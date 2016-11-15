class ActivityCollectionDecorator < BaseDecorator
  attr_reader :collection, :total_pages

  def initialize(activities)
    @collection = activities

    @object = @collection.map { |activity| ActivityDecorator.new(activity) }
  end
end
