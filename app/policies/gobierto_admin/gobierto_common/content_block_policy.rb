# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class ContentBlockPolicy
      attr_reader :admin, :content_block

      def initialize(admin, content_block = nil)
        @admin = admin
        @content_block = content_block
      end

      def view?
        true
      end

      def create?
        manage?
      end

      def update?
        manage?
      end

      def delete?
        manage?
      end

      private

      def manage?
        admin.managing_user?
      end
    end
  end
end
