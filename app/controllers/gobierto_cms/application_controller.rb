# frozen_string_literal: true

module GobiertoCms
  class ApplicationController < ::ApplicationController
    include User::SessionHelper

    layout 'gobierto_cms/layouts/application'

    before_action { module_enabled!(current_site, 'GobiertoCms') }
  end
end
