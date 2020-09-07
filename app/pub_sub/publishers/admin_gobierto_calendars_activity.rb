# frozen_string_literal: true

module Publishers
  class AdminGobiertoCalendarsActivity
    include Publisher

    self.pub_sub_namespace = 'activities/admin_gobierto_calendars'
  end
end
