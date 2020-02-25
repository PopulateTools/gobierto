# frozen_string_literal: true

class CommonFactory

  def self.site(params = {})
    organization_name = params[:organization_name] || "Badajoz"

    name_translations = {
      en: "City council of #{organization_name}",
      es: "Ayuntamiento de #{organization_name}",
    }

    configuration_data = {
      modules: [
        "GobiertoBudgets",
        "GobiertoBudgetConsultations",
        "GobiertoPeople",
        "GobiertoCms",
        "GobiertoParticipation",
        "GobiertoIndicators",
        "GobiertoPlans",
        "GobiertoCitizensCharters",
        "GobiertoObservatory",
        "GobiertoInvestments",
        "GobiertoData"
      ],
      default_locale: "en",
      available_locales: ["en", "es"],
      home_page: "GobiertoParticipation"
    }

    Site.create!(
      title_translations: name_translations,
      name_translations: name_translations,
      domain: "#{organization_name.downcase}.gobierto.test",
      configuration_data: configuration_data,
      organization_name: organization_name,
      organization_id: "123",
      organization_url: "http://example.com",
      organization_type: "Ayuntamiento",
      reply_to_email: "contact@example.com",
      organization_address: "Fake St., 123",
      organization_document_number: "0123456789A",
      visibility_level: "active"
    )
  end

end
