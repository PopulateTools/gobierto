# frozen_string_literal: true

class UserNotificationCollectionDecorator < BaseDecorator
  attr_reader :collection, :total_pages

  def initialize(user_notifications)
    @collection = user_notifications

    @object = @collection.map { |user_notification| UserNotificationDecorator.new(user_notification) }
  end
end
