# frozen_string_literal: true

module Publisher
  extend ::ActiveSupport::Concern
  extend self

  included do
    class_attribute :pub_sub_namespace

    self.pub_sub_namespace = nil
  end

  # delegate to class method
  def broadcast_event(event_name, payload = {})
    if block_given?
      self.class.broadcast_event(event_name, payload) do
        yield
      end
    else
      self.class.broadcast_event(event_name, payload)
    end
  end

  module ClassMethods
    def broadcast_event(event_name, payload = {})
      event_name = [pub_sub_namespace, event_name].compact.join(".")

      if allowed_for_publication?(event_name, payload)
        register_allowed_event(event_name, payload)
      else
        Rails.logger.debug("Blocking event \"#{event_name}\" with payload: #{payload}")
        return
      end

      if block_given?
        ActiveSupport::Notifications.instrument(event_name, payload) do
          yield
        end
      else
        ActiveSupport::Notifications.instrument(event_name, payload)
      end
    end

    def allowed_for_publication?(event_name, payload)
      !$redis.get(key_for_event(event_name, payload))
    end

    def register_allowed_event(event_name, payload)
      event_key = key_for_event(event_name, payload)

      Rails.logger.debug("Allowing event \"#{event_name}\" with payload: #{payload}")
      $redis.set(event_key, true)
      $redis.expire(event_key, 60)
    end

    def key_for_event(event_name, payload)
      [event_name, Digest::MD5.hexdigest(payload.to_json)].join("-")
    end
  end
end
