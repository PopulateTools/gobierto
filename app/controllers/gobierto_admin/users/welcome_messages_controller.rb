# frozen_string_literal: true

module GobiertoAdmin
  class Users::WelcomeMessagesController < BaseController
    def create
      @user_welcome_message_form = UserWelcomeMessageForm.new(
        id: params[:user_id]
      )

      if @user_welcome_message_form.save
        flash[:notice] = t(".success")
      else
        flash[:alert] = t(".error")
      end

      redirect_to request.referrer
    end
  end
end
