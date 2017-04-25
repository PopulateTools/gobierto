module GobiertoPeople
  module People
    class PastPersonEventsController < People::PersonEventsController
      def index

        if params[:date]
          @filtering_date = Date.parse(params[:date])
          @events = @person.events.by_date(@filtering_date).sorted.page params[:page]
        else
          @events = @person.events.past.sorted.page params[:page]
        end

        @calendar_events = @person.events

        respond_to do |format|
          format.js { render 'gobierto_people/people/person_events/index' }
          format.html
        end
      end
    end
  end
end
