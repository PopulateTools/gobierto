module GobiertoPeople
  class ApplicationController < ::ApplicationController
    include User::SessionHelper

    layout "gobierto_people/layouts/application"
  end
end
