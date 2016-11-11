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
      if block_given?
        ActiveSupport::Notifications.instrument(event_name, payload) do
          yield
        end
      else
        Rails.logger.info [event_name, self.pub_sub_namespace].join(' - ')
        ActiveSupport::Notifications.instrument(event_name, payload)
      end
    end
  end
end
