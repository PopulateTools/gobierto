# frozen_string_literal: true

# Builds the responses Rack::Attack returns when a request is rate limited or
# blocked.
#
# This runs in a middleware: there is no controller, no view context and no
# locale set yet. The messages are literals rather than I18n keys because the
# translation backend is database backed (I18n::Backend::Gobierto), and querying
# the database on the requests we are shedding defeats the purpose.
class RackAttackResponder
  DEFAULT_LOCALE = "es"
  LOCALES = %w(es en ca).freeze
  LOCALE_FROM_PATH = %r{\A/(es|en|ca)(?:/|\z)}.freeze
  MINIMUM_RETRY_AFTER = 5

  THROTTLED_MESSAGES = {
    "es" => {
      title: "Demasiadas peticiones",
      heading: "Estamos recibiendo demasiadas peticiones desde tu conexión",
      body: "Para mantener este portal disponible para todo el mundo limitamos temporalmente el número de peticiones por conexión.",
      wait: "Vuelve a intentarlo en unos segundos.",
      link: "Volver al inicio"
    },
    "en" => {
      title: "Too many requests",
      heading: "We are receiving too many requests from your connection",
      body: "To keep this portal available for everyone we temporarily limit the number of requests per connection.",
      wait: "Please try again in a few seconds.",
      link: "Back to the home page"
    },
    "ca" => {
      title: "Massa peticions",
      heading: "Estem rebent massa peticions des de la teva connexió",
      body: "Per mantenir aquest portal disponible per a tothom limitem temporalment el nombre de peticions per connexió.",
      wait: "Torna-ho a provar en uns segons.",
      link: "Tornar a l'inici"
    }
  }.freeze

  BLOCKED_MESSAGES = {
    "es" => {
      title: "Petición no permitida",
      heading: "Esta petición no está permitida",
      body: "La dirección solicitada no es válida.",
      wait: "",
      link: "Volver al inicio"
    },
    "en" => {
      title: "Request not allowed",
      heading: "This request is not allowed",
      body: "The requested address is not valid.",
      wait: "",
      link: "Back to the home page"
    },
    "ca" => {
      title: "Petició no permesa",
      heading: "Aquesta petició no està permesa",
      body: "L'adreça sol·licitada no és vàlida.",
      wait: "",
      link: "Tornar a l'inici"
    }
  }.freeze

  class << self
    def throttled(request)
      respond(request, status: 429, messages: THROTTLED_MESSAGES, retry_after: retry_after_for(request))
    end

    def blocklisted(request)
      respond(request, status: 403, messages: BLOCKED_MESSAGES, retry_after: nil)
    end

    def locale_for(request)
      locale_from_path(request) || locale_from_site(request) || locale_from_accept_language(request) || DEFAULT_LOCALE
    end

    # Anything the browser will not paint as a page gets JSON: the calendar
    # fetch, the visualization endpoints and the .json/.csv routes.
    def wants_json?(request)
      return true if request.path.end_with?(".json", ".csv")
      return true if request.get_header("HTTP_X_REQUESTED_WITH").to_s.casecmp("xmlhttprequest").zero?

      accept = request.get_header("HTTP_ACCEPT").to_s
      accept.include?("application/json") && !accept.include?("text/html")
    end

    def retry_after_for(request)
      match_data = request.env["rack.attack.match_data"] || {}
      period = match_data[:period].to_i
      return MINIMUM_RETRY_AFTER if period.zero?

      [period - (match_data[:epoch_time].to_i % period), MINIMUM_RETRY_AFTER].max
    end

    private

    def respond(request, status:, messages:, retry_after:)
      locale = locale_for(request)
      strings = messages.fetch(locale, messages.fetch(DEFAULT_LOCALE))

      headers = { "Cache-Control" => "no-store", "Content-Language" => locale }
      headers["Retry-After"] = retry_after.to_s if retry_after

      if wants_json?(request)
        headers["Content-Type"] = "application/json; charset=utf-8"
        body = { error: { status: status, message: strings[:heading], retry_after: retry_after }.compact }.to_json
      else
        headers["Content-Type"] = "text/html; charset=utf-8"
        body = html(strings, status: status, locale: locale)
      end

      [status, headers, [body]]
    end

    def locale_from_path(request)
      LOCALE_FROM_PATH.match(request.path)&.captures&.first
    end

    # OverrideWelcomeAction runs before Rack::Attack and has already loaded the
    # site, so reading its configuration costs no extra query.
    def locale_from_site(request)
      locale = request.env["gobierto_site"]&.configuration&.default_locale.to_s
      locale if LOCALES.include?(locale)
    rescue StandardError
      nil
    end

    def locale_from_accept_language(request)
      request.get_header("HTTP_ACCEPT_LANGUAGE").to_s
             .split(",")
             .map { |tag| tag.split(";").first.to_s.strip.downcase[0, 2] }
             .find { |tag| LOCALES.include?(tag) }
    end

    def html(strings, status:, locale:)
      <<~HTML
        <!DOCTYPE html>
        <html lang="#{locale}">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width,initial-scale=1">
          <meta name="robots" content="noindex">
          <title>#{strings[:title]} (#{status})</title>
          <style>
            body { background-color: #EFEFEF; color: #2E2F30; text-align: center; font-family: arial, sans-serif; margin: 0; }
            div.dialog { width: 95%; max-width: 33em; margin: 4em auto 0; }
            div.dialog > div { border: 1px solid #CCC; border-top: #B00100 solid 4px; border-top-left-radius: 9px;
                               border-top-right-radius: 9px; background-color: white; padding: 7px 12% 1em;
                               box-shadow: 0 3px 8px rgba(50, 50, 50, 0.17); }
            h1 { font-size: 100%; color: #730E15; line-height: 1.5em; }
            p { color: #666; }
            a { color: #730E15; }
          </style>
        </head>
        <body>
          <div class="dialog">
            <div>
              <h1>#{strings[:heading]}</h1>
              <p>#{strings[:body]}</p>
              <p>#{strings[:wait]}</p>
              <p><a href="/">#{strings[:link]}</a></p>
            </div>
          </div>
        </body>
        </html>
      HTML
    end
  end
end
