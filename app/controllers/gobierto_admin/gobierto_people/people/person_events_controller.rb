module GobiertoAdmin
  module GobiertoPeople
    module People
      class PersonEventsController < People::BaseController
        def index
          @person_events = @person.events.sorted
          @person_events_presenter = PersonEventsPresenter.new(@person)
        end

        def new
          @person_event_form = PersonEventForm.new
          @attendees = get_attendees
          @person_event_states = get_person_event_states
        end

        def edit
          @person_event = find_person_event
          @person_event_states = get_person_event_states

          @person_event_form = PersonEventForm.new(
            @person_event.attributes.except(*ignored_person_event_attributes)
          )
          @attendees = get_attendees
        end

        def create
          @person_event_form = PersonEventForm.new(
            person_event_params.merge(person_id: @person.id, admin_id: current_admin.id, site_id: current_site.id)
          )

          if @person_event_form.save
            redirect_to(
              edit_admin_people_person_event_path(@person, @person_event_form.person_event),
              notice: t(".success_html", link: gobierto_people_person_event_url(@person, @person_event_form.person_event))
            )
          else
            @attendees = get_attendees
            @person_event_states = get_person_event_states
            render :new
          end
        end

        def update
          @person_event = find_person_event
          @person_event_form = PersonEventForm.new(
            person_event_params.merge(id: params[:id], admin_id: current_admin.id, site_id: current_site.id)
          )

          if @person_event_form.save
            redirect_to(
              edit_admin_people_person_event_path(@person, @person_event),
              notice: t(".success_html", link: gobierto_people_person_event_url(@person, @person_event_form.person_event))
            )
          else
            @attendees = get_attendees
            @person_event_states = get_person_event_states
            render :edit
          end
        end

        private

        def find_person_event
          @person.events.find(params[:id])
        end

        def get_attendees
          current_site.people
            .where.not(id: @person.id)
            .active
            .select(:id, :name)
        end

        def get_person_event_states
          ::GobiertoPeople::PersonEvent.states
        end

        def person_event_params
          params.require(:person_event).permit(
            :title,
            :description,
            :starts_at,
            :ends_at,
            :attachment_file,
            :state,
            locations_attributes: [:id, :name, :address, :lat, :lng, :_destroy],
            attendees_attributes: [:id, :person_id, :name, :charge, :_destroy]
          )
        end

        def ignored_person_event_attributes
          %w(
          created_at updated_at
          )
        end
      end
    end
  end
end
