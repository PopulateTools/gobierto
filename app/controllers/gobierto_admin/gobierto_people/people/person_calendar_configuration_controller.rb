module GobiertoAdmin
  module GobiertoPeople
    module People
      class PersonCalendarConfigurationController < BaseController
        before_action { module_enabled!(current_site, 'GobiertoPeople') }

        def edit
          @calendar_configuration_form = PersonCalendarConfigurationForm.new(person_id: @person.id)

          render 'gobierto_admin/gobierto_people/people/person_events/person_calendar_configuration/edit'
        end

        def update
          @calendar_configuration_form = PersonCalendarConfigurationForm.new(
            calendar_configuration_params.merge(person_id: @person.id)
          )

          @calendar_configuration_form.save
          redirect_to(
            edit_admin_people_person_calendar_configuration_path,
            notice: t('gobierto_admin.gobierto_people.people.person_events.person_calendar_configuration.success')
          )
        end

        private

        def calendar_configuration_params
          params.require(:calendar_configuration).permit(
            :ibm_notes_url
          )
        end

      end
    end
  end
end
