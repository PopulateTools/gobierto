module Publisher
  extend ::ActiveSupport::Concern
  extend self

  included do
    class_attribute :pub_sub_namespace

    self.pub_sub_namespace = nil
  end

  # delegate to class method
  def broadcast_event(event_name, payload={})
    if block_given?
      self.class.broadcast_event(event_name, payload) do
        yield
      end
    else
      self.class.broadcast_event(event_name, payload)
    end
  end

  module ClassMethods
    def broadcast_event(event_name, payload={})
      event_name = [pub_sub_namespace, event_name].compact.join('.')
      return if !allowed_for_publication?(event_name, payload)

      if block_given?
        ActiveSupport::Notifications.instrument(event_name, payload) do
          yield
        end
      else
        ActiveSupport::Notifications.instrument(event_name, payload)
      end
    end

    def allowed_for_publication?(event_name, payload)
      event_key = key_for_event(event_name, payload)
      if $redis.get(event_key)
        Rails.logger.debug("Blocking event \"#{event_name}\" with payload: #{payload}")
        return false
      else
        Rails.logger.debug("Allowing event \"#{event_name}\" with payload: #{payload}")
        $redis.set(event_key, true)
        $redis.expire(event_key, 60)
        return true
      end
    end

    def key_for_event(event_name, payload)
      [event_name, Digest::MD5.hexdigest(payload.to_json)].join('-')
    end
  end
end
