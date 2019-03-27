# frozen_string_literal: true

module GobiertoPeople
  module People
    class PersonMessagesController < BaseController

      before_action :check_person_has_email
      invisible_captcha(
        only: [:create],
        honeypot: :ic_email,
        scope: :gobierto_people_person_message
      )

      def new
        @person_message = GobiertoPeople::PersonMessage.new(default_params)
      end

      def create
        @person_message = GobiertoPeople::PersonMessage.new(
          person_message_params.merge(default_params.merge(person: @person))
        )

        if @person_message.valid?
          @person_message.deliver!

          redirect_to new_gobierto_people_person_messages_path(@person.slug), notice: t(".success")
        else
          flash.now[:alert] = t(".error")
          render "new"
        end
      end

      private

      def person_message_params
        params.require(:gobierto_people_person_message).permit(:name, :email, :body)
      end

      def default_params
        if user_signed_in?
          { name: current_user.name, email: current_user.email }
        else
          {}
        end
      end

      def check_person_has_email
        if @person.email.blank?
          redirect_to gobierto_people_person_path(@person.slug)
        end
      end
    end
  end
end
