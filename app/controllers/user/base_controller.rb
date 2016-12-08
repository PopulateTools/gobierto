class User::BaseController < ApplicationController
  include User::SessionHelper
  include User::VerificationHelper

  layout "application"
end
