# frozen_string_literal: true

module GobiertoPeople
  module People
    class GiftsController < BaseController

      before_action :check_active_submodules

      def index
        @person_gifts = @person.received_gifts.between_dates(filter_start_date, filter_end_date)
      end

      def show
        @gift = @person.received_gifts.find(params[:id])
      end

      private

      def check_active_submodules
        redirect_to gobierto_people_root_path unless gifts_submodule_active?
      end

    end
  end
end
