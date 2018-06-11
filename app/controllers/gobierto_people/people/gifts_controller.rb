# frozen_string_literal: true

module GobiertoPeople
  module People
    class GiftsController < BaseController
      def index
        @person_gifts = @person.received_gifts
      end

      def show
        @gift = @person.received_gifts.find(params[:id])
      end
    end
  end
end
