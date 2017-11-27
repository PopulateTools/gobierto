module GobiertoAdmin
  module GobiertoCalendars
    class CalendarConfigurationController < GobiertoAdmin::BaseController

      # TODO: will need to adapt to process calendar synchronization
      before_action { module_enabled!(current_site, 'GobiertoPeople') }
      before_action { module_allowed!(current_admin, 'GobiertoPeople') }

      def edit
        load_collection
        @calendar_configuration_form = CalendarConfigurationForm.new(collection_id: @collection.id)
        load_calendar_integrations
        @google_calendar_configuration = find_google_calendar_configuration
        load_calendars

        render 'gobierto_admin/gobierto_calendars/calendar_configuration/edit'
      end

      def update
        load_collection

        @calendar_configuration_form = CalendarConfigurationForm.new(
          calendar_configuration_params.merge(collection_id: @collection.id)
        )

        if @calendar_configuration_form.save
          redirect_to(
            edit_admin_calendars_configuration_path(@collection),
            notice: t('.success')
          )
        else
          load_calendar_integrations
          render 'gobierto_admin/gobierto_calendars/calendar_configuration/edit'
        end
      end

      private

      def load_collection
        @collection = ::GobiertoCommon::Collection.find(params[:id])
      end

      def load_calendar_integrations
        @calendar_integrations_options = find_calendar_integrations
      end

      def calendar_configuration_params
        params.require(:calendar_configuration).permit(
          :calendar_integration,
          :ibm_notes_usr,
          :ibm_notes_pwd,
          :ibm_notes_url,
          :microsoft_exchange_usr,
          :microsoft_exchange_pwd,
          :microsoft_exchange_url,
          :clear_calendar_configuration,
          calendars: []
        )
      end

      def find_google_calendar_configuration
        if configuration = ::GobiertoCalendars::GoogleCalendarConfiguration.find_by(collection_id: @collection.id)
          if configuration.google_calendar_credentials.blank?
            nil
          else
            configuration
          end
        end
      end

      def load_calendars
        if calendar_service
          @calendars = calendar_service.calendars
        else
          @calendars = []
        end
      end

      def calendar_service
        @calendar_service ||= if @google_calendar_configuration
                                ::GobiertoPeople::GoogleCalendar::CalendarIntegration.new(person)
                              end
      end

      # TODO: will need to adapt to process calendar synchronization
      def person
        @collection.container
      end

      def find_calendar_integrations
        ::GobiertoPeople.remote_calendar_integrations.map do |integration_name|
          [
            I18n.t("gobierto_admin.gobierto_calendars.calendar_configuration.edit.#{integration_name}"),
            integration_name
          ]
        end
      end

    end
  end
end
