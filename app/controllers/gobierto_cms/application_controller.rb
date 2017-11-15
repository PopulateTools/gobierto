module GobiertoCms
  class ApplicationController < ::ApplicationController
    include User::SessionHelper

    layout "gobierto_cms/layouts/application"
  end
end
