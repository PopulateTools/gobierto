# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoDashboards
    class DashboardsController < GobiertoAdmin::BaseController
      layout false

      def index
        @context = "context"
      end

      def show
        # dashboard ID/context example
        @id = 0
        @context = "context"
      end
    end
  end
end