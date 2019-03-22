module GobiertoAdmin
  module GobiertoCalendars
    class CalendarConfigurationController < GobiertoAdmin::BaseController

      # TODO: will need to adapt to process calendar synchronization
      before_action { module_enabled!(current_site, 'GobiertoPeople') }
      before_action { module_allowed!(current_admin, 'GobiertoPeople') }

      before_action :load_collection, :collection_container_allowed!

      def edit
        @calendar_configuration_form = CalendarConfigurationForm.new(current_site: current_site, collection: @collection)
        load_calendar_integrations
        @google_calendar_configuration = find_google_calendar_configuration
        load_calendars
        set_last_sync

        render 'gobierto_admin/gobierto_calendars/calendar_configuration/edit'
      end

      def update
        @calendar_configuration_form = CalendarConfigurationForm.new(
          calendar_configuration_params.merge(current_site: current_site, collection: @collection)
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

      def sync_calendars
        browser_locale = I18n.locale
        I18n.locale = current_site.configuration.default_locale

        @calendar_configuration_form = CalendarConfigurationForm.new(
          current_site: current_site,
          collection: @collection
        )

        if (calendar_integration = @calendar_configuration_form.calendar_integration_class).present?
          calendar_integration.new(@calendar_configuration_form.collection_container).sync!
          publish_calendar_sync_activity(@calendar_configuration_form)

          I18n.locale = browser_locale

          redirect_to(
            edit_admin_calendars_configuration_path(@collection),
            notice: t(".success")
          )
        end
      rescue ::GobiertoCalendars::CalendarIntegration::Error => e
        I18n.locale = browser_locale
        redirect_to(
          edit_admin_calendars_configuration_path(@collection),
          alert: e.message
        )
      end

      private

      def publish_calendar_sync_activity(calendar_configuration_form)
        Publishers::AdminGobiertoCalendarsActivity.broadcast_event('calendars_synchronized', { ip: remote_ip, author: current_admin, subject: calendar_configuration_form.collection_container, site_id: current_site.id })
      end

      def set_last_sync
        @last_sync = if collection_container = @calendar_configuration_form.try(:collection_container)
                       current_site.activities.where(action: 'admin_gobierto_calendars.calendars_synchronized', subject: collection_container)
                         .order(created_at: :asc)
                         .last.try(:created_at)
                     end
      end

      def load_collection
        @collection = current_site.collections.find(params[:id])
      end

      def load_calendar_integrations
        @calendar_integrations_options = find_calendar_integrations
      end

      def collection_container
        @collection.container
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
          :without_description,
          filtering_rules_attributes: [:id, :field, :condition, :value, :action, :_destroy, :remove_filtering_text],
          calendars: []
        )
      end

      def find_google_calendar_configuration
        if configuration = ::GobiertoCalendars::GoogleCalendarConfiguration.find_by(collection: @collection)
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
                                ::GobiertoPeople::GoogleCalendar::CalendarIntegration.new(collection_container)
                              end
      end

      def find_calendar_integrations
        ::GobiertoPeople.remote_calendar_integrations.map do |integration_name|
          [
            I18n.t("gobierto_admin.gobierto_calendars.calendar_configuration.edit.#{integration_name}"),
            integration_name
          ]
        end
      end

      def collection_container_allowed!
        if collection_container.class == ::GobiertoPeople::Person
          if !can_manage_person?(collection_container)
            redirect_to admin_people_people_path, alert: t('gobierto_admin.admin_unauthorized')
          end
        end
      end

      def can_manage_person?(person)
        ::GobiertoAdmin::GobiertoPeople::PersonPolicy.new(current_admin: current_admin, current_site: current_site, person: person).manage?
      end

    end
  end
end
