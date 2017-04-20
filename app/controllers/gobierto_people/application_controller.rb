module GobiertoPeople
  class ApplicationController < ::ApplicationController
    include User::SessionHelper

    layout "gobierto_people/layouts/application"

    before_action { module_enabled!(current_site, "GobiertoPeople") }
  end
end
