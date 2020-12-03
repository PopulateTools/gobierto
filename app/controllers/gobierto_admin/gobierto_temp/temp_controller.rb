# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoTemp
    class TempController < GobiertoAdmin::BaseController
      layout false

      def index
      end

      def show
        # dashboard ID example
        @id = 0 
      end
    end
  end
end