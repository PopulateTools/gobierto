# frozen_string_literal: true

module SiteSessionHelpers
  def with_current_site(site)
    GobiertoSiteConstraint.stub_any_instance(:matches?, true) do
      ApplicationController.stub_any_instance(:current_site, site) do
        GobiertoAdmin::BaseController.stub_any_instance(:current_site, SiteDecorator.new(site)) do
          yield
        end
      end
    end
  end
end