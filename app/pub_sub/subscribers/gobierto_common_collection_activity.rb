module Subscribers
  class GobiertoCommonCollectionActivity < ::Subscribers::Base
    def collection_created(event)
      create_activity_from_event(event, 'gobierto_common.collection_created')
    end

    def collection_updated(event)
      create_activity_from_event(event, 'gobierto_common.collection_updated')
    end

    private

    def create_activity_from_event(event, action)
      Activity.create! subject: event.payload[:subject],
                       author: event.payload[:author],
                       subject_ip: event.payload[:ip],
                       action: action,
                       site_id: event.payload[:site_id],
                       admin_activity: true
    end
  end
end
