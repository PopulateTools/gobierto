# frozen_string_literal: true

class User::BaseController < ApplicationController
  include User::SessionHelper
  include User::VerificationHelper

  layout "user/layouts/application"
end
