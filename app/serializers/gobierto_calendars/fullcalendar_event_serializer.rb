class GobiertoCalendars::FullcalendarEventSerializer < ActiveModel::Serializer

  attributes :id, :title, :start, :end, :url

  def start
    object.starts_at
  end

  def end
    object.ends_at
  end

  def url
    domain = instance_options[:current_site].domain
    person_slug = instance_options[:person_slug]
    only_calendar = instance_options[:only_calendar]
    extra_params = { host: "portalobert.esplugues.cat" }
    extra_params[:only_calendar] = true if only_calendar
    Rails.application.routes.url_helpers.gobierto_people_person_event_url(person_slug, object.slug, extra_params)
  end

end
