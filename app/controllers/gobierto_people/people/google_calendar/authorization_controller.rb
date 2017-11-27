module GobiertoPeople
  module People
    module GoogleCalendar
      class AuthorizationController < ::ApplicationController
        skip_before_action :set_current_site, :authenticate_user_in_site, :set_locale
        before_action :load_person, :load_google_calendar_configuration

        def new
          scope = [Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY]

          if params[:code].nil?
            session[:google_calendar_person_id] = @person.id

            client_id = Google::Auth::ClientId.from_file(client_secret_path)
            token_store = Google::Auth::Stores::FileTokenStore.new(file: Tempfile.new.path)
            authorizer = Google::Auth::WebUserAuthorizer.new(client_id, scope, token_store, new_gobierto_people_google_calendar_authorization_path)

            redirect_to authorizer.get_authorization_url(login_hint: @person.id, request: request)
          else
            client_secrets = Google::APIClient::ClientSecrets.load(client_secret_path)

            auth_client = client_secrets.to_authorization
            auth_client.update!(:scope => scope)
            auth_client.code = params[:code]
            auth_client.fetch_access_token!
            auth_client.client_secret = nil
            @configuration.google_calendar_credentials = { GobiertoPeople::GoogleCalendar::CalendarIntegration::USERNAME => auth_client.to_json }.to_yaml
            @configuration.save!

            redirect_to edit_gobierto_people_person_google_calendar_calendars_url(@person.slug, host: @person.site.domain), notice: t('.success')
          end
        end

        private

        def load_person
          @person = if params[:token]
                      GobiertoPeople::Person.find_by! google_calendar_token: params[:token]
                    else
                      GobiertoPeople::Person.find session[:google_calendar_person_id]
                    end
        end

        def load_google_calendar_configuration
          @configuration = ::GobiertoCalendars::GoogleCalendarConfiguration.find_by(collection_id: @person.calendar.id)
          @configuration.integration_name = 'google_calendar'
        end

        def client_secret_path
          GobiertoPeople::GoogleCalendar::CalendarIntegration::CLIENT_SECRETS_PATH
        end
      end
    end
  end
end
