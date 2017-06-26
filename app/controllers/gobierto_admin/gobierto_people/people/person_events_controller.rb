module GobiertoAdmin
  module GobiertoPeople
    module People
      class PersonEventsController < People::BaseController

        helper_method :gobierto_people_person_event_preview_url

        def index
          @person_events = @person.events.sorted
          @person_events_presenter = PersonEventsPresenter.new(@person)
        end

        def new
          @person_event_form = PersonEventForm.new
          @attendees = get_attendees
          @person_event_states = get_calendar_event_states
        end

        def edit
          @person_event = find_person_event
          @person_event_states = get_calendar_event_states

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
              notice: t(".success_html", link: gobierto_people_person_event_preview_url(@person, @person_event_form.person_event, host: current_site.domain))
            )
          else
            @attendees = get_attendees
            @person_event_states = get_calendar_event_states
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
              notice: t(".success_html", link: gobierto_people_person_event_preview_url(@person, @person_event_form.person_event, host: current_site.domain))
            )
          else
            @attendees = get_attendees
            @person_event_states = get_calendar_event_states
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

        def get_calendar_event_states
          ::GobiertoCalendars::Event.states
        end

        def person_event_params
          params.require(:person_event).permit(
            :starts_at,
            :ends_at,
            :attachment_file,
            :state,
            locations_attributes: [:id, :name, :address, :lat, :lng, :_destroy],
            attendees_attributes: [:id, :person_id, :name, :charge, :_destroy],
            title_translations: [*I18n.available_locales],
            description_translations: [*I18n.available_locales]
          )
        end

        def ignored_person_event_attributes
          %w( created_at updated_at title description external_id slug site_id )
        end

        def gobierto_people_person_event_preview_url(person, event, options = {})
          if event.pending? || event.person.draft?
            options.merge!(preview_token: current_admin.preview_token)
          end
          gobierto_people_person_event_url(person.slug, event.slug, options)
        end

      end
    end
  end
end
