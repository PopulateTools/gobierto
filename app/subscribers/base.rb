# frozen_string_literal: true

module Subscribers
  class Base
    attr_reader :namespace

    def initialize(namespace)
      @namespace = namespace
    end

    # attach public methods of subscriber with events in the namespace
    def self.attach_to(namespace)
      log_subscriber = new(namespace)
      log_subscriber.public_methods(false).each do |event|
        ActiveSupport::Notifications.subscribe("#{namespace}.#{event}", log_subscriber)
      end
    end

    # trigger methods when an event is captured
    def call(message, *args)
      method  = message.gsub("#{namespace}.", "")
      handler = self.class.new(namespace)
      handler.send(method, ActiveSupport::Notifications::Event.new(message, *args))
    end
  end
end
