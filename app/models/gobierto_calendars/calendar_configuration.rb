require_dependency 'gobierto_calendars'

module GobiertoCalendars
  class CalendarConfiguration < ApplicationRecord

    belongs_to :collection, class_name: 'GobiertoCommon::Collection'

    validates :collection_id, :integration_name, :data, presence: true

    def subject_filter
      data['filters'] && data['filters']['subject']
    end
  end
end
